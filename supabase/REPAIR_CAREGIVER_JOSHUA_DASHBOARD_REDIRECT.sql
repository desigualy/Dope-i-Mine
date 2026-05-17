-- Hard repair + verification for caregiver dashboard access.
--
-- Target caregiver: joshua.harrisuk@yahoo.com
--
-- This fixes the actual dashboard prerequisite, not just the route flag:
--   1) Joshua must be account_type='caregiver'
--   2) Joshua must have caregiver_profiles row
--   3) Joshua must have onboarding_completed=true
--   4) Joshua must have at least one ACCEPTED caregiver_relationships row
--      where caregiver_user_id = Joshua's users_profile.id
--
-- Why this exists:
-- The app's /caregiver screen only opens the real linked-user dashboard when
-- it can load an accepted relationship where currentUser.id == caregiver_user_id.
-- If that relationship is missing, reversed, revoked, pending, or attached to
-- the wrong accepted_user_id, Joshua gets stranded on the generic support page.

begin;

-- 0) Diagnostic snapshot BEFORE repair.
select
  'BEFORE_PROFILE' as section,
  up.id,
  up.email,
  up.account_type,
  up.onboarding_completed,
  up.onboarding_completed_at
from public.users_profile up
where lower(up.email) = lower('joshua.harrisuk@yahoo.com');

select
  'BEFORE_INVITES' as section,
  i.id,
  i.inviter_user_id,
  inviter.email as inviter_email,
  i.invitee_email,
  i.status,
  i.accepted_user_id,
  accepted.email as accepted_email,
  i.accepted_at,
  i.role
from public.caregiver_email_invites i
left join public.users_profile inviter on inviter.id = i.inviter_user_id
left join public.users_profile accepted on accepted.id = i.accepted_user_id
where lower(i.invitee_email) = lower('joshua.harrisuk@yahoo.com')
   or lower(accepted.email) = lower('joshua.harrisuk@yahoo.com')
order by i.created_at desc;

select
  'BEFORE_RELATIONSHIPS' as section,
  cr.id,
  cr.caregiver_user_id,
  caregiver.email as caregiver_email,
  cr.supported_user_id,
  supported.email as supported_email,
  cr.role,
  cr.status,
  cr.accepted_at,
  cr.revoked_at
from public.caregiver_relationships cr
left join public.users_profile caregiver on caregiver.id = cr.caregiver_user_id
left join public.users_profile supported on supported.id = cr.supported_user_id
where lower(caregiver.email) = lower('joshua.harrisuk@yahoo.com')
   or lower(supported.email) = lower('joshua.harrisuk@yahoo.com')
order by cr.created_at desc;

-- 1) Ensure Joshua's profile is unambiguously a caregiver account and completed.
with joshua as (
  select id, email
  from public.users_profile
  where lower(email) = lower('joshua.harrisuk@yahoo.com')
  limit 1
), repaired_profile as (
  update public.users_profile up
  set account_type = 'caregiver',
      onboarding_completed = true,
      onboarding_completed_at = coalesce(up.onboarding_completed_at, now()),
      updated_at = now()
  from joshua j
  where up.id = j.id
  returning up.id, up.email
)
insert into public.caregiver_profiles (
  user_id,
  contact_email,
  verification_status,
  updated_at
)
select
  rp.id,
  rp.email,
  'unverified',
  now()
from repaired_profile rp
on conflict (user_id) do update
  set contact_email = excluded.contact_email,
      updated_at = now();

-- 2) Repair/create the accepted caregiver relationship from Joshua's accepted invite.
-- This handles the common broken state where the invite says accepted_user_id=Joshua
-- but caregiver_relationships is missing/revoked/pending/wrong status.
with joshua as (
  select id, email
  from public.users_profile
  where lower(email) = lower('joshua.harrisuk@yahoo.com')
  limit 1
), accepted_invite as (
  select i.*
  from public.caregiver_email_invites i
  join joshua j on j.id = i.accepted_user_id
  where lower(i.invitee_email) = lower(j.email)
    and i.status = 'accepted'
  order by i.accepted_at desc nulls last, i.created_at desc
  limit 1
), repaired_relationship as (
  insert into public.caregiver_relationships (
    caregiver_user_id,
    supported_user_id,
    role,
    status,
    accepted_at,
    revoked_at
  )
  select
    ai.accepted_user_id,
    ai.inviter_user_id,
    ai.role,
    'accepted',
    coalesce(ai.accepted_at, now()),
    null
  from accepted_invite ai
  where ai.accepted_user_id is not null
    and ai.inviter_user_id <> ai.accepted_user_id
  on conflict (caregiver_user_id, supported_user_id) do update
    set role = excluded.role,
        status = 'accepted',
        accepted_at = coalesce(public.caregiver_relationships.accepted_at, excluded.accepted_at, now()),
        revoked_at = null
  returning *
)
select
  'REPAIRED_FROM_ACCEPTED_INVITE' as section,
  rr.id,
  rr.caregiver_user_id,
  rr.supported_user_id,
  rr.role,
  rr.status,
  rr.accepted_at
from repaired_relationship rr;

-- 3) If no accepted invite row was properly stamped but a pending/accepted invite
-- exists for Joshua's email, mark the latest one accepted and create the relationship.
-- This covers invite flows that created the caregiver auth/profile but failed before
-- caregiver_email_invites.accepted_user_id was updated.
with joshua as (
  select id, email
  from public.users_profile
  where lower(email) = lower('joshua.harrisuk@yahoo.com')
  limit 1
), latest_invite as (
  select i.*
  from public.caregiver_email_invites i
  join joshua j on lower(i.invitee_email) = lower(j.email)
  where i.status in ('pending', 'accepted')
  order by
    case when i.status = 'accepted' then 0 else 1 end,
    i.accepted_at desc nulls last,
    i.created_at desc
  limit 1
), stamped_invite as (
  update public.caregiver_email_invites i
  set status = 'accepted',
      accepted_user_id = j.id,
      accepted_at = coalesce(i.accepted_at, now())
  from latest_invite li
  cross join joshua j
  where i.id = li.id
    and i.inviter_user_id <> j.id
  returning i.*
), repaired_relationship as (
  insert into public.caregiver_relationships (
    caregiver_user_id,
    supported_user_id,
    role,
    status,
    accepted_at,
    revoked_at
  )
  select
    si.accepted_user_id,
    si.inviter_user_id,
    si.role,
    'accepted',
    coalesce(si.accepted_at, now()),
    null
  from stamped_invite si
  where si.accepted_user_id is not null
    and si.inviter_user_id <> si.accepted_user_id
  on conflict (caregiver_user_id, supported_user_id) do update
    set role = excluded.role,
        status = 'accepted',
        accepted_at = coalesce(public.caregiver_relationships.accepted_at, excluded.accepted_at, now()),
        revoked_at = null
  returning *
)
select
  'REPAIRED_FROM_LATEST_INVITE' as section,
  rr.id,
  rr.caregiver_user_id,
  rr.supported_user_id,
  rr.role,
  rr.status,
  rr.accepted_at
from repaired_relationship rr;

-- 4) Final verification. The final query MUST return at least one row with:
-- account_type='caregiver', onboarding_completed=true, relationship_status='accepted'.
select
  'AFTER_DASHBOARD_REQUIREMENTS' as section,
  caregiver.id as caregiver_user_id,
  caregiver.email as caregiver_email,
  caregiver.account_type,
  caregiver.onboarding_completed,
  cp.user_id is not null as has_caregiver_profile,
  cr.id as relationship_id,
  cr.status as relationship_status,
  cr.role,
  supported.id as supported_user_id,
  supported.email as supported_email,
  cr.accepted_at,
  cr.revoked_at
from public.users_profile caregiver
left join public.caregiver_profiles cp on cp.user_id = caregiver.id
left join public.caregiver_relationships cr
  on cr.caregiver_user_id = caregiver.id
 and cr.status = 'accepted'
 and cr.revoked_at is null
left join public.users_profile supported on supported.id = cr.supported_user_id
where lower(caregiver.email) = lower('joshua.harrisuk@yahoo.com')
order by cr.accepted_at desc nulls last;

commit;