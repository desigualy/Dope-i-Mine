-- Track suggested caregivers who accepted an auth invite but still need to set
-- a password before they can sign in with email/password.

alter table public.caregiver_email_invites
  add column if not exists requires_password_setup boolean not null default false;

alter table public.caregiver_email_invites
  add column if not exists password_setup_sent_at timestamptz null;

create index if not exists caregiver_email_invites_password_setup_idx
  on public.caregiver_email_invites (accepted_user_id, requires_password_setup, password_setup_sent_at)
  where requires_password_setup = true;
