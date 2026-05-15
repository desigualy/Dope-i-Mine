-- Caregiver management actions: revoke active links and cancel pending email invites.
-- These RPCs keep removal idempotent and enforce that only a relationship party or
-- invite creator can perform the action.

create or replace function public.cancel_caregiver_email_invite(p_invite_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $cancel_invite$
declare
  v_user_id uuid := auth.uid();
  v_invite public.caregiver_email_invites%rowtype;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  select * into v_invite
  from public.caregiver_email_invites
  where id = p_invite_id
  for update;

  if not found then
    raise exception 'Caregiver invite not found';
  end if;

  if v_invite.inviter_user_id <> v_user_id then
    raise exception 'Not allowed to cancel this caregiver invite';
  end if;

  if v_invite.status = 'pending' then
    update public.caregiver_email_invites
    set status = 'revoked'
    where id = p_invite_id;
  end if;
end;
$cancel_invite$;

grant execute on function public.cancel_caregiver_email_invite(uuid) to authenticated;

create or replace function public.revoke_caregiver_relationship(p_relationship_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $revoke_relationship$
declare
  v_user_id uuid := auth.uid();
  v_relationship public.caregiver_relationships%rowtype;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  select * into v_relationship
  from public.caregiver_relationships
  where id = p_relationship_id
  for update;

  if not found then
    raise exception 'Caregiver relationship not found';
  end if;

  if v_relationship.caregiver_user_id <> v_user_id
      and v_relationship.supported_user_id <> v_user_id then
    raise exception 'Not allowed to remove this caregiver relationship';
  end if;

  if v_relationship.status <> 'revoked' then
    update public.caregiver_relationships
    set status = 'revoked',
        revoked_at = now()
    where id = p_relationship_id;
  end if;
end;
$revoke_relationship$;

grant execute on function public.revoke_caregiver_relationship(uuid) to authenticated;

create index if not exists caregiver_relationships_active_visibility_idx
  on public.caregiver_relationships (caregiver_user_id, supported_user_id, status)
  where status in ('pending', 'accepted');

create index if not exists caregiver_email_invites_pending_inviter_idx
  on public.caregiver_email_invites (inviter_user_id, status, created_at desc)
  where status = 'pending';
