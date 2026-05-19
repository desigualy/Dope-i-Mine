alter table public.users_profile
  add column if not exists must_change_password boolean not null default false;

alter table public.users_profile
  add column if not exists temporary_password_created_at timestamptz null;

alter table public.caregiver_email_invites
  add column if not exists temporary_password_set_at timestamptz null;

alter table public.caregiver_email_invites
  add column if not exists requires_password_setup boolean not null default false;

alter table public.caregiver_email_invites
  add column if not exists password_setup_sent_at timestamptz null;

create index if not exists users_profile_must_change_password_idx
  on public.users_profile (id, must_change_password)
  where must_change_password = true;

select pg_notify('pgrst', 'reload schema');