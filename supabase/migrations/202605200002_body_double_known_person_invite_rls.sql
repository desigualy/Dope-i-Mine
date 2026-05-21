-- Phase 3C/3D hardening:
-- Move strict known-person invite RLS here because caregiver_relationships
-- is created after the original body-double friend migration.
--
-- This migration must run after:
--   202605110001_caregiver_phase1.sql

do $$
begin
  if to_regclass('public.body_double_invites') is null then
    raise exception 'public.body_double_invites does not exist. Run body double phase 2 migration first.';
  end if;

  if to_regclass('public.caregiver_relationships') is null then
    raise exception 'public.caregiver_relationships does not exist. Run caregiver phase 1 migration first.';
  end if;
end $$;

drop policy if exists "body_double_invites_sender_insert"
  on public.body_double_invites;

create policy "body_double_invites_sender_insert"
  on public.body_double_invites
  for insert
  with check (
    auth.uid() = sender_id
    and exists (
      select 1
      from public.caregiver_relationships r
      where r.status = 'accepted'
        and r.revoked_at is null
        and (
          (
            r.caregiver_user_id = sender_id
            and r.supported_user_id = receiver_id
          )
          or
          (
            r.supported_user_id = sender_id
            and r.caregiver_user_id = receiver_id
          )
        )
    )
  );

drop policy if exists "body_double_invites_visible_to_sender_or_receiver"
  on public.body_double_invites;

create policy "body_double_invites_visible_to_sender_or_receiver"
  on public.body_double_invites
  for select
  using (
    auth.uid() = sender_id
    or auth.uid() = receiver_id
  );

drop policy if exists "body_double_invites_receiver_or_sender_update"
  on public.body_double_invites;

create policy "body_double_invites_receiver_or_sender_update"
  on public.body_double_invites
  for update
  using (
    auth.uid() = sender_id
    or auth.uid() = receiver_id
  )
  with check (
    auth.uid() = sender_id
    or auth.uid() = receiver_id
  );

select pg_notify('pgrst', 'reload schema');
