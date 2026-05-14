-- Email-first caregiver invites.
-- A caregiver/support person does not need an existing account at invite time.

create table if not exists public.caregiver_email_invites (
  id uuid primary key default gen_random_uuid(),
  inviter_user_id uuid not null references public.users_profile(id) on delete cascade,
  invitee_email text not null,
  role public.caregiver_role not null default 'caregiver',
  status text not null default 'pending' check (status in ('pending', 'accepted', 'expired', 'revoked')),
  accepted_user_id uuid null references public.users_profile(id) on delete set null,
  created_at timestamptz not null default now(),
  accepted_at timestamptz null,
  expires_at timestamptz null,
  unique(inviter_user_id, invitee_email)
);

alter table public.caregiver_email_invites enable row level security;

drop policy if exists "caregiver_email_invites_inviter_select" on public.caregiver_email_invites;
create policy "caregiver_email_invites_inviter_select"
  on public.caregiver_email_invites for select
  using (auth.uid() = inviter_user_id);

drop policy if exists "caregiver_email_invites_inviter_insert" on public.caregiver_email_invites;
create policy "caregiver_email_invites_inviter_insert"
  on public.caregiver_email_invites for insert
  with check (auth.uid() = inviter_user_id);

drop policy if exists "caregiver_email_invites_inviter_update" on public.caregiver_email_invites;
create policy "caregiver_email_invites_inviter_update"
  on public.caregiver_email_invites for update
  using (auth.uid() = inviter_user_id)
  with check (auth.uid() = inviter_user_id);

create index if not exists caregiver_email_invites_invitee_email_idx
  on public.caregiver_email_invites (lower(invitee_email));