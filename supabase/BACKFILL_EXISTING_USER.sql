-- Insert profile for the existing user who signed up before the migration
-- User ID: 04d18d48-5c1b-404e-a394-113a4ed59d6c
-- Run this in the Supabase SQL Editor (uses service role, bypasses RLS)
--
-- IMPORTANT:
-- - This script should only create the missing profile row.
-- - It must not reset onboarding_completed for an existing row, otherwise the
--   app will route an already-onboarded user back into onboarding.

alter table public.users_profile
  add column if not exists onboarding_completed boolean not null default false,
  add column if not exists onboarding_completed_at timestamptz;

insert into public.users_profile (
  id,
  email,
  display_name,
  age_band,
  default_mode,
  voice_enabled,
  onboarding_completed,
  onboarding_completed_at
)
values (
  '04d18d48-5c1b-404e-a394-113a4ed59d6c',
  'recycleyourit@yahoo.com',
  null,
  'teen',
  'audhd',
  true,
  false,
  null
)
on conflict (id) do nothing;

