-- Fix accept_pending_caregiver_email_invites and accept_caregiver_email_invite
-- to handle bidirectional invites (Caregiver -> User and User -> Caregiver)

create or replace function public.accept_pending_caregiver_email_invites()
returns integer
language plpgsql
security definer
set search_path = public
as $accept_pending_invites$
declare
  v_user_id uuid := auth.uid();
  v_user_email text;
  v_invite record;
  v_inviter_account_type text;
  v_accepted_count integer := 0;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  select email into v_user_email
  from public.users_profile
  where id = v_user_id;

  if v_user_email is null or position('@' in v_user_email) = 0 then
    return 0;
  end if;

  for v_invite in
    select *
    from public.caregiver_email_invites
    where lower(invitee_email) = lower(v_user_email)
      and status = 'pending'
      and (expires_at is null or expires_at >= now())
    for update
  loop
    select account_type into v_inviter_account_type
    from public.users_profile
    where id = v_invite.inviter_user_id;

    if v_inviter_account_type = 'caregiver' then
      -- Inviter is Caregiver, Invitee is Supported User
      insert into public.caregiver_relationships (
        caregiver_user_id,
        supported_user_id,
        role,
        status,
        accepted_at
      ) values (
        v_invite.inviter_user_id,
        v_user_id,
        v_invite.role,
        'accepted',
        now()
      )
      on conflict (caregiver_user_id, supported_user_id) do update
        set role = excluded.role,
            status = 'accepted',
            accepted_at = now(),
            revoked_at = null;
    else
      -- Inviter is Supported User, Invitee becomes Caregiver
      if v_accepted_count = 0 then
        update public.users_profile
        set account_type = 'caregiver',
            updated_at = now()
        where id = v_user_id;

        insert into public.caregiver_profiles (
          user_id,
          contact_email,
          verification_status,
          updated_at
        ) values (
          v_user_id,
          v_user_email,
          'unverified',
          now()
        )
        on conflict (user_id) do update
          set contact_email = excluded.contact_email,
              updated_at = now();
      end if;

      insert into public.caregiver_relationships (
        caregiver_user_id,
        supported_user_id,
        role,
        status,
        accepted_at
      ) values (
        v_user_id,
        v_invite.inviter_user_id,
        v_invite.role,
        'accepted',
        now()
      )
      on conflict (caregiver_user_id, supported_user_id) do update
        set role = excluded.role,
            status = 'accepted',
            accepted_at = now(),
            revoked_at = null;
    end if;

    update public.caregiver_email_invites
    set status = 'accepted',
        accepted_user_id = v_user_id,
        accepted_at = now()
    where id = v_invite.id;

    v_accepted_count := v_accepted_count + 1;
  end loop;

  update public.caregiver_email_invites
  set status = 'expired'
  where lower(invitee_email) = lower(v_user_email)
    and status = 'pending'
    and expires_at is not null
    and expires_at < now();

  return v_accepted_count;
end;
$accept_pending_invites$;


create or replace function public.accept_caregiver_email_invite(p_invite_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $accept_invite$
declare
  v_invite public.caregiver_email_invites%rowtype;
  v_user_id uuid := auth.uid();
  v_user_email text;
  v_inviter_account_type text;
  v_relationship jsonb;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  select email into v_user_email
  from public.users_profile
  where id = v_user_id;

  select * into v_invite
  from public.caregiver_email_invites
  where id = p_invite_id
  for update;

  if not found then
    raise exception 'Caregiver invite not found';
  end if;

  if v_invite.status <> 'pending' then
    raise exception 'Caregiver invite is not pending';
  end if;

  if v_invite.expires_at is not null and v_invite.expires_at < now() then
    update public.caregiver_email_invites
    set status = 'expired'
    where id = p_invite_id;
    raise exception 'Caregiver invite has expired';
  end if;

  if lower(coalesce(v_user_email, '')) <> lower(v_invite.invitee_email) then
    raise exception 'Caregiver invite email mismatch';
  end if;

  select account_type into v_inviter_account_type
  from public.users_profile
  where id = v_invite.inviter_user_id;

  if v_inviter_account_type = 'caregiver' then
    -- Inviter is Caregiver, Invitee is Supported User
    insert into public.caregiver_relationships (
      caregiver_user_id,
      supported_user_id,
      role,
      status,
      accepted_at
    ) values (
      v_invite.inviter_user_id,
      v_user_id,
      v_invite.role,
      'accepted',
      now()
    )
    on conflict (caregiver_user_id, supported_user_id) do update
      set role = excluded.role,
          status = 'accepted',
          accepted_at = now(),
          revoked_at = null
    returning jsonb_build_object(
      'id', id,
      'caregiver_user_id', caregiver_user_id,
      'supported_user_id', supported_user_id,
      'role', role,
      'status', status,
      'relationship_label', relationship_label,
      'created_at', created_at,
      'accepted_at', accepted_at,
      'revoked_at', revoked_at
    ) into v_relationship;

  else
    -- Inviter is Supported User, Invitee becomes Caregiver
    update public.users_profile
    set account_type = 'caregiver',
        updated_at = now()
    where id = v_user_id;

    insert into public.caregiver_profiles (
      user_id,
      contact_email,
      verification_status,
      updated_at
    ) values (
      v_user_id,
      v_user_email,
      'unverified',
      now()
    )
    on conflict (user_id) do update
      set contact_email = excluded.contact_email,
          updated_at = now();

    insert into public.caregiver_relationships (
      caregiver_user_id,
      supported_user_id,
      role,
      status,
      accepted_at
    ) values (
      v_user_id,
      v_invite.inviter_user_id,
      v_invite.role,
      'accepted',
      now()
    )
    on conflict (caregiver_user_id, supported_user_id) do update
      set role = excluded.role,
          status = 'accepted',
          accepted_at = now(),
          revoked_at = null
    returning jsonb_build_object(
      'id', id,
      'caregiver_user_id', caregiver_user_id,
      'supported_user_id', supported_user_id,
      'role', role,
      'status', status,
      'relationship_label', relationship_label,
      'created_at', created_at,
      'accepted_at', accepted_at,
      'revoked_at', revoked_at
    ) into v_relationship;
  end if;

  update public.caregiver_email_invites
  set status = 'accepted',
      accepted_user_id = v_user_id,
      accepted_at = now()
  where id = p_invite_id;

  return v_relationship;
end;
$accept_invite$;

grant execute on function public.accept_pending_caregiver_email_invites() to authenticated;
grant execute on function public.accept_caregiver_email_invite(uuid) to authenticated;
