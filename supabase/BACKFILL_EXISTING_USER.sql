-- Insert profile for the existing user who signed up before the migration
-- User ID: 04d18d48-5c1b-404e-a394-113a4ed59d6c
-- Run this in the Supabase SQL Editor (uses service role, bypasses RLS)

insert into public.users_profile (id, email, display_name, age_band, default_mode, voice_enabled)
values (
  '04d18d48-5c1b-404e-a394-113a4ed59d6c',
  'recycleyourit@yahoo.com',
  null,
  'teen',
  'audhd',
  true
)
on conflict (id) do nothing;
