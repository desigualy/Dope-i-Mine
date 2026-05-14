-- Accept caregiver email invites after the invitee opens the emailed magic link.

do $do_caregiver_role$
begin
  create type public.caregiver_role as enum ('caregiver', 'overseer', 'monitor');
exception
  when duplicate_object then null;
end;
$do_caregiver_role$;

do $do_caregiver_relationship_status$
begin
  create type public.caregiver_relationship_status as enum ('pending', 'accepted', 'declined', 'blocked', 'revoked');
exception
  when duplicate_object then null;
end;
$do_caregiver_relationship_status$;

create table if not exists public.caregiver_relationships (
  id uuid primary key default gen_random_uuid(),
  caregiver_user_id uuid not null references public.users_profile(id) on delete cascade,
  supported_user_id uuid not null references public.users_profile(id) on delete cascade,
  role public.caregiver_role not null default 'caregiver',
  status public.caregiver_relationship_status not null default 'pending',
  relationship_label text null,
  created_at timestamptz not null default now(),
  accepted_at timestamptz null,
  revoked_at timestamptz null,
  unique(caregiver_user_id, supported_user_id)
);

create table if not exists public.caregiver_email_invites (
  id uuid primary key default gen_random_uuid(),
  inviter_user_id uuid not null references public.users_profile(id) on delete cascade,
  invitee_email text not null,
  role public.caregiver_role not null default 'caregiver',
  status text not null default 'pending' check (status in ('pending', 'accepted', 'expired', 'revoked')),
  accepted_user_id uuid null references public.users_profile(id) on delete set null,
  created_at timestamptz not null default now(),
  accepted_at timestamptz null,
  expires_at timestamptz null,
  unique(inviter_user_id, invitee_email)
);

alter table public.caregiver_email_invites enable row level security;

drop policy if exists "caregiver_email_invites_inviter_select" on public.caregiver_email_invites;
create policy "caregiver_email_invites_inviter_select"
  on public.caregiver_email_invites for select
  using (auth.uid() = inviter_user_id);

drop policy if exists "caregiver_email_invites_inviter_insert" on public.caregiver_email_invites;
create policy "caregiver_email_invites_inviter_insert"
  on public.caregiver_email_invites for insert
  with check (auth.uid() = inviter_user_id);

drop policy if exists "caregiver_email_invites_inviter_update" on public.caregiver_email_invites;
create policy "caregiver_email_invites_inviter_update"
  on public.caregiver_email_invites for update
  using (auth.uid() = inviter_user_id)
  with check (auth.uid() = inviter_user_id);

create index if not exists caregiver_email_invites_invitee_email_idx
  on public.caregiver_email_invites (lower(invitee_email));

alter table public.caregiver_relationships enable row level security;

drop policy if exists "caregiver_relationships_visibility" on public.caregiver_relationships;
create policy "caregiver_relationships_visibility"
  on public.caregiver_relationships for select
  using (auth.uid() = caregiver_user_id or auth.uid() = supported_user_id);

drop policy if exists "caregiver_relationships_insert" on public.caregiver_relationships;
create policy "caregiver_relationships_insert"
  on public.caregiver_relationships for insert
  with check (auth.uid() = caregiver_user_id or auth.uid() = supported_user_id);

drop policy if exists "caregiver_relationships_update" on public.caregiver_relationships;
create policy "caregiver_relationships_update"
  on public.caregiver_relationships for update
  using (auth.uid() = caregiver_user_id or auth.uid() = supported_user_id);

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

  update public.caregiver_email_invites
  set status = 'accepted',
      accepted_user_id = v_user_id,
      accepted_at = now()
  where id = p_invite_id;

  return v_relationship;
end;
$accept_invite$;

grant execute on function public.accept_caregiver_email_invite(uuid) to authenticated;

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

  for v_invite in
    select *
    from public.caregiver_email_invites
    where lower(invitee_email) = lower(v_user_email)
      and status = 'pending'
      and (expires_at is null or expires_at >= now())
    for update
  loop
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

grant execute on function public.accept_pending_caregiver_email_invites() to authenticated;