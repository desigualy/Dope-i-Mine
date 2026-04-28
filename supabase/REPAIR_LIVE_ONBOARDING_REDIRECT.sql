-- ============================================================================
-- REPAIR LIVE ONBOARDING REDIRECT STATE
-- ============================================================================
-- Run this in the Supabase SQL Editor for project:
-- https://supabase.com/dashboard/project/ohdvpbzivjcrwsxadpnp/sql
--
-- Why this exists:
-- - local Flutter code/tests can be correct
-- - but the live database may still have onboarding_completed = false
-- - or may still be using the older signup trigger definition
-- - either case will keep redirecting the user to onboarding

-- --------------------------------------------------------------------------
-- 0) Ensure the explicit onboarding columns exist first
-- --------------------------------------------------------------------------
alter table public.users_profile
  add column if not exists onboarding_completed boolean not null default false,
  add column if not exists onboarding_completed_at timestamptz;

-- --------------------------------------------------------------------------
-- 1) Inspect the current row for the affected existing user
-- --------------------------------------------------------------------------
select
  id,
  email,
  onboarding_completed,
  onboarding_completed_at
from public.users_profile
where id = '04d18d48-5c1b-404e-a394-113a4ed59d6c'
   or email = 'recycleyourit@yahoo.com';

do $$
begin
  if to_regclass('public.assistant_identity_settings') is not null then
    raise notice 'assistant_identity_settings exists for user: %',
      exists (
        select 1
        from public.assistant_identity_settings
        where user_id = '04d18d48-5c1b-404e-a394-113a4ed59d6c'
      );
  else
    raise notice 'assistant_identity_settings table does not exist';
  end if;

  if to_regclass('public.sensory_settings') is not null then
    raise notice 'sensory_settings exists for user: %',
      exists (
        select 1
        from public.sensory_settings
        where user_id = '04d18d48-5c1b-404e-a394-113a4ed59d6c'
      );
  else
    raise notice 'sensory_settings table does not exist';
  end if;
end
$$;

-- --------------------------------------------------------------------------
-- 2) Reapply the safe signup trigger in the live DB
-- --------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users_profile (id, email, display_name)
  values (new.id, new.email, new.raw_user_meta_data->>'display_name')
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute procedure public.handle_new_user();

-- --------------------------------------------------------------------------
-- 3) IMPORTANT: do NOT auto-backfill onboarding_completed from the presence of
--    onboarding-related rows. That heuristic can misclassify users and force a
--    redirect to Home when they should still go through onboarding.
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
-- 4) IMPORTANT: choose ONE of the following only if needed.
--
-- A) If the user should be considered COMPLETE, run:
-- update public.users_profile
-- set
--   onboarding_completed = true,
--   onboarding_completed_at = coalesce(onboarding_completed_at, now())
-- where id = '04d18d48-5c1b-404e-a394-113a4ed59d6c';
--
-- B) If the user should go through onboarding AGAIN, run:
-- update public.users_profile
-- set
--   onboarding_completed = false,
--   onboarding_completed_at = null
-- where id = '04d18d48-5c1b-404e-a394-113a4ed59d6c';

-- --------------------------------------------------------------------------
-- 5) Verify final state
-- --------------------------------------------------------------------------
select
  id,
  email,
  onboarding_completed,
  onboarding_completed_at
from public.users_profile
where id = '04d18d48-5c1b-404e-a394-113a4ed59d6c';
