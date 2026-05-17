-- Add explicit onboarding completion columns for older deployed databases.
--
-- IMPORTANT:
-- We intentionally do NOT auto-mark users as onboarding-complete here.
-- Presence of onboarding-related rows is not a safe proof that the user should
-- skip onboarding, and it can wrongly redirect users to Home.
--
-- Completion must be set explicitly by the app when onboarding finishes, or by
-- a deliberate manual repair script for a known user.

alter table public.users_profile
  add column if not exists onboarding_completed boolean not null default false,
  add column if not exists onboarding_completed_at timestamptz;