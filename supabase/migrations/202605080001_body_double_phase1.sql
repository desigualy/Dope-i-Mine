-- Body Double System foundation.
-- Phase 1 ships Dope-i body doubling in-app first; these tables reserve the
-- server-side contract for syncing Dope-i summaries and safely extending to
-- consent-based friend sessions and safety-critical random sessions later.

create table if not exists public.body_double_sessions (
  id uuid primary key default gen_random_uuid(),
  client_session_id text null,
  user_id uuid not null references auth.users(id) on delete cascade,
  mode text not null check (mode in ('dopei', 'friend', 'random')),
  status text not null check (
    status in ('waiting', 'active', 'paused', 'completed', 'cancelled', 'reported')
  ),
  task_id uuid null,
  session_type text not null default 'quickStart',
  session_length_minutes integer null,
  communication_mode text not null default 'quiet',
  privacy_level text not null default 'private',
  check_in_interval_minutes integer not null default 5,
  steps_completed integer not null default 0,
  overwhelm_events integer not null default 0,
  summary text null,
  started_at timestamptz null,
  ended_at timestamptz null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.body_double_sessions
  add column if not exists client_session_id text null;

alter table public.body_double_sessions
  add column if not exists communication_mode text not null default 'quiet';

alter table public.body_double_sessions
  add column if not exists privacy_level text not null default 'private';

alter table public.body_double_sessions
  add column if not exists session_type text not null default 'quickStart';

alter table public.body_double_sessions
  add column if not exists check_in_interval_minutes integer not null default 5;

alter table public.body_double_sessions
  add column if not exists steps_completed integer not null default 0;

alter table public.body_double_sessions
  add column if not exists overwhelm_events integer not null default 0;

alter table public.body_double_sessions
  add column if not exists summary text null;

alter table public.body_double_sessions
  add column if not exists updated_at timestamptz not null default now();

create index if not exists body_double_sessions_user_created_idx
  on public.body_double_sessions(user_id, created_at desc);

create unique index if not exists body_double_sessions_user_client_session_idx
  on public.body_double_sessions(user_id, client_session_id)
  where client_session_id is not null;

alter table public.body_double_sessions enable row level security;

drop policy if exists "Users can read own body double sessions"
  on public.body_double_sessions;
create policy "Users can read own body double sessions"
  on public.body_double_sessions
  for select
  using (auth.uid() = user_id);

drop policy if exists "Users can insert own body double sessions"
  on public.body_double_sessions;
create policy "Users can insert own body double sessions"
  on public.body_double_sessions
  for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users can update own body double sessions"
  on public.body_double_sessions;
create policy "Users can update own body double sessions"
  on public.body_double_sessions
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Future phases must add separate participant/invite/report/queue tables with
-- consent, age gates, anonymous defaults, block/report, and no adult/minor
-- random matching before enabling human/random body double modes.