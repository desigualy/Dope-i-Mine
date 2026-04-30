-- Side Quests
create table if not exists side_quests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users_profile(id) on delete cascade,
  task_id uuid references tasks(id) on delete cascade,
  routine_id uuid, -- For routine-specific side quests
  title text not null,
  quest_type text not null, -- 'mindfulness', 'energy', 'hydration', etc.
  reward_xp integer not null default 50,
  status text not null default 'available', -- 'available', 'accepted', 'completed', 'dismissed'
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Enable RLS for side_quests
alter table side_quests enable row level security;
drop policy if exists "Users can view their own side quests" on side_quests;
drop policy if exists "Users can insert their own side quests" on side_quests;
drop policy if exists "Users can update their own side quests" on side_quests;
create policy "Users can view their own side quests" on side_quests for select using (auth.uid() = user_id);
create policy "Users can insert their own side quests" on side_quests for insert with check (auth.uid() = user_id);
create policy "Users can update their own side quests" on side_quests for update using (auth.uid() = user_id);

-- Rewards (XP Tracking)
create table if not exists rewards (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users_profile(id) on delete cascade,
  reward_type text not null, -- 'xp', 'streak'
  reward_key text not null, -- 'step_complete', 'task_complete', 'side_quest_complete'
  amount integer not null default 0,
  source_type text, -- 'task', 'step', 'side_quest'
  source_id uuid,
  created_at timestamptz default now()
);

-- Enable RLS for rewards
alter table rewards enable row level security;
drop policy if exists "Users can view their own rewards" on rewards;
drop policy if exists "Users can insert their own rewards" on rewards;
create policy "Users can view their own rewards" on rewards for select using (auth.uid() = user_id);
create policy "Users can insert their own rewards" on rewards for insert with check (auth.uid() = user_id);

-- Routines
create table if not exists routines (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users_profile(id) on delete cascade,
  title text not null,
  age_band text not null,
  is_template boolean not null default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Enable RLS for routines
alter table routines enable row level security;
drop policy if exists "Users can view their own routines" on routines;
drop policy if exists "Users can insert their own routines" on routines;
drop policy if exists "Users can update their own routines" on routines;
create policy "Users can view their own routines" on routines for select using (auth.uid() = user_id);
create policy "Users can insert their own routines" on routines for insert with check (auth.uid() = user_id);
create policy "Users can update their own routines" on routines for update using (auth.uid() = user_id);

create table if not exists routine_steps (
  id uuid primary key default gen_random_uuid(),
  routine_id uuid not null references routines(id) on delete cascade,
  parent_step_id uuid references routine_steps(id) on delete cascade,
  depth_level integer not null default 0,
  sequence_no integer not null,
  step_text text not null,
  is_optional boolean not null default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Enable RLS for routine_steps
alter table routine_steps enable row level security;
drop policy if exists "Users can view their own routine steps" on routine_steps;
drop policy if exists "Users can insert their own routine steps" on routine_steps;
drop policy if exists "Users can update their own routine steps" on routine_steps;
create policy "Users can view their own routine steps" on routine_steps for select using (exists (select 1 from routines where routines.id = routine_steps.routine_id and routines.user_id = auth.uid()));
create policy "Users can insert their own routine steps" on routine_steps for insert with check (exists (select 1 from routines where routines.id = routine_steps.routine_id and routines.user_id = auth.uid()));
create policy "Users can update their own routine steps" on routine_steps for update using (exists (select 1 from routines where routines.id = routine_steps.routine_id and routines.user_id = auth.uid()));
