-- Body Double System Phase 2: trusted friend/caregiver body doubling.
-- Sessions must start only after participant consent. Privacy is explicit and
-- no hidden surveillance is allowed.

create table if not exists public.body_double_participants (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.body_double_sessions(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'participant',
  status text not null default 'invited' check (
    status in ('invited', 'accepted', 'declined', 'active', 'left', 'removed')
  ),
  age_band_snapshot text null,
  display_name_snapshot text null,
  anonymous_label text null,
  joined_at timestamptz null,
  left_at timestamptz null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(session_id, user_id)
);

create table if not exists public.body_double_invites (
  id uuid primary key default gen_random_uuid(),
  client_invite_id text unique null,
  session_id uuid null references public.body_double_sessions(id) on delete cascade,
  session_client_id text null,
  sender_id uuid not null references auth.users(id) on delete cascade,
  receiver_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'pending' check (
    status in ('pending', 'accepted', 'declined', 'expired', 'cancelled')
  ),
  expires_at timestamptz not null,
  created_at timestamptz not null default now(),
  responded_at timestamptz null
);

create table if not exists public.body_double_presence (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.body_double_sessions(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'still_here',
  updated_at timestamptz not null default now(),
  unique(session_id, user_id)
);

create table if not exists public.body_double_messages (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.body_double_sessions(id) on delete cascade,
  sender_id uuid not null references auth.users(id) on delete cascade,
  message_type text not null default 'preset' check (
    message_type in ('preset', 'system')
  ),
  body text not null,
  created_at timestamptz not null default now()
);

create index if not exists body_double_participants_user_idx
  on public.body_double_participants(user_id, created_at desc);

create index if not exists body_double_invites_receiver_idx
  on public.body_double_invites(receiver_id, created_at desc);

alter table public.body_double_participants enable row level security;
alter table public.body_double_invites enable row level security;
alter table public.body_double_presence enable row level security;
alter table public.body_double_messages enable row level security;

drop policy if exists "body_double_participants_visible_to_participant"
  on public.body_double_participants;

create policy "body_double_participants_visible_to_participant"
  on public.body_double_participants
  for select
  using (
    auth.uid() = user_id
    or exists (
      select 1
      from public.body_double_participants p
      where p.session_id = body_double_participants.session_id
        and p.user_id = auth.uid()
    )
  );

drop policy if exists "body_double_participants_self_insert"
  on public.body_double_participants;

create policy "body_double_participants_self_insert"
  on public.body_double_participants
  for insert
  with check (auth.uid() = user_id);

drop policy if exists "body_double_participants_self_update"
  on public.body_double_participants;

create policy "body_double_participants_self_update"
  on public.body_double_participants
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "body_double_invites_visible_to_sender_or_receiver"
  on public.body_double_invites;

create policy "body_double_invites_visible_to_sender_or_receiver"
  on public.body_double_invites
  for select
  using (
    auth.uid() = sender_id
    or auth.uid() = receiver_id
  );

-- IMPORTANT:
-- This early migration must NOT reference public.caregiver_relationships,
-- because caregiver_relationships is created later in 202605110001_caregiver_phase1.sql.
-- The stricter known-person RLS is added later in
-- 202605200002_body_double_known_person_invite_rls.sql.
drop policy if exists "body_double_invites_sender_insert"
  on public.body_double_invites;

create policy "body_double_invites_sender_insert"
  on public.body_double_invites
  for insert
  with check (auth.uid() = sender_id);

drop policy if exists "body_double_invites_receiver_or_sender_update"
  on public.body_double_invites;

create policy "body_double_invites_receiver_or_sender_update"
  on public.body_double_invites
  for update
  using (
    auth.uid() = sender_id
    or auth.uid() = receiver_id
  )
  with check (
    auth.uid() = sender_id
    or auth.uid() = receiver_id
  );

drop policy if exists "body_double_presence_visible_to_session_participants"
  on public.body_double_presence;

create policy "body_double_presence_visible_to_session_participants"
  on public.body_double_presence
  for select
  using (
    exists (
      select 1
      from public.body_double_participants p
      where p.session_id = body_double_presence.session_id
        and p.user_id = auth.uid()
    )
  );

drop policy if exists "body_double_presence_self_all"
  on public.body_double_presence;

create policy "body_double_presence_self_all"
  on public.body_double_presence
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "body_double_messages_visible_to_session_participants"
  on public.body_double_messages;

create policy "body_double_messages_visible_to_session_participants"
  on public.body_double_messages
  for select
  using (
    exists (
      select 1
      from public.body_double_participants p
      where p.session_id = body_double_messages.session_id
        and p.user_id = auth.uid()
    )
  );

drop policy if exists "body_double_messages_sender_insert"
  on public.body_double_messages;

create policy "body_double_messages_sender_insert"
  on public.body_double_messages
  for insert
  with check (auth.uid() = sender_id);

select pg_notify('pgrst', 'reload schema');
