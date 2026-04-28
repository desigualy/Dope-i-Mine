-- ============================================================================
-- RESET LIVE USER TO ONBOARDING
-- ============================================================================
-- Use this when the app is wrongly sending the existing user to Home and you
-- want that user to be routed into onboarding again.
--
-- Run in Supabase SQL Editor:
-- https://supabase.com/dashboard/project/ohdvpbzivjcrwsxadpnp/sql

alter table public.users_profile
  add column if not exists onboarding_completed boolean not null default false,
  add column if not exists onboarding_completed_at timestamptz;

update public.users_profile
set
  onboarding_completed = false,
  onboarding_completed_at = null
where id = '04d18d48-5c1b-404e-a394-113a4ed59d6c'
   or email = 'recycleyourit@yahoo.com';

select
  id,
  email,
  onboarding_completed,
  onboarding_completed_at
from public.users_profile
where id = '04d18d48-5c1b-404e-a394-113a4ed59d6c'
   or email = 'recycleyourit@yahoo.com';