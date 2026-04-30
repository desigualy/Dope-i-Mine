-- ============================================================
-- FULL MIGRATION — Run this once in Supabase SQL Editor
-- ============================================================

-- 1. users_profile
create table if not exists users_profile (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  display_name text,
  age_band text default 'teen',
  default_mode text not null default 'audhd',
  voice_enabled boolean not null default true,
  onboarding_completed boolean not null default false,
  onboarding_completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table users_profile enable row level security;
drop policy if exists "Users can view their own profile" on users_profile;
drop policy if exists "Users can insert their own profile" on users_profile;
drop policy if exists "Users can update their own profile" on users_profile;
create policy "Users can view their own profile" on users_profile for select using (auth.uid() = id);
create policy "Users can insert their own profile" on users_profile for insert with check (auth.uid() = id);
create policy "Users can update their own profile" on users_profile for update using (auth.uid() = id);

-- 2. Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.users_profile (id, email, display_name)
  values (new.id, new.email, new.raw_user_meta_data->>'display_name')
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer set search_path = public;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 3. assistant_identity_settings
create table if not exists assistant_identity_settings (
  user_id uuid primary key references users_profile(id) on delete cascade,
  assistant_display_name text not null default 'Dope-i',
  pronunciation_key text not null default 'dope_ee',
  updated_at timestamptz not null default now()
);
alter table assistant_identity_settings enable row level security;
drop policy if exists "Users can view their own assistant identity settings" on assistant_identity_settings;
drop policy if exists "Users can insert their own assistant identity settings" on assistant_identity_settings;
drop policy if exists "Users can update their own assistant identity settings" on assistant_identity_settings;
drop policy if exists "Users can delete their own assistant identity settings" on assistant_identity_settings;
create policy "Users can view their own assistant identity settings" on assistant_identity_settings for select using (auth.uid() = user_id);
create policy "Users can insert their own assistant identity settings" on assistant_identity_settings for insert with check (auth.uid() = user_id);
create policy "Users can update their own assistant identity settings" on assistant_identity_settings for update using (auth.uid() = user_id);
create policy "Users can delete their own assistant identity settings" on assistant_identity_settings for delete using (auth.uid() = user_id);

-- 4. sensory_settings
create table if not exists sensory_settings (
  user_id uuid primary key references users_profile(id) on delete cascade,
  reduced_animation boolean not null default false,
  large_text boolean not null default false,
  sound_enabled boolean not null default true,
  soft_colors boolean not null default true,
  praise_level text not null default 'medium',
  icon_mode boolean not null default false,
  reduce_surprises boolean not null default true,
  updated_at timestamptz not null default now()
);
alter table sensory_settings enable row level security;
drop policy if exists "Users can view their own sensory settings" on sensory_settings;
drop policy if exists "Users can insert their own sensory settings" on sensory_settings;
drop policy if exists "Users can update their own sensory settings" on sensory_settings;
drop policy if exists "Users can delete their own sensory settings" on sensory_settings;
create policy "Users can view their own sensory settings" on sensory_settings for select using (auth.uid() = user_id);
create policy "Users can insert their own sensory settings" on sensory_settings for insert with check (auth.uid() = user_id);
create policy "Users can update their own sensory settings" on sensory_settings for update using (auth.uid() = user_id);
create policy "Users can delete their own sensory settings" on sensory_settings for delete using (auth.uid() = user_id);

-- 5. Tasks
create table if not exists tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users_profile(id) on delete cascade,
  source_text text not null,
  normalized_title text not null,
  category text,
  status text not null default 'active' check (status in ('active', 'completed', 'paused', 'cancelled')),
  mode_used text not null,
  energy_level text not null,
  stress_level text not null,
  time_available text not null,
  effort_band text not null default 'medium',
  estimated_minutes integer not null default 15,
  state_snapshot jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table tasks enable row level security;
drop policy if exists "Users can view their own tasks" on tasks;
drop policy if exists "Users can insert their own tasks" on tasks;
drop policy if exists "Users can update their own tasks" on tasks;
create policy "Users can view their own tasks" on tasks for select using (auth.uid() = user_id);
create policy "Users can insert their own tasks" on tasks for insert with check (auth.uid() = user_id);
create policy "Users can update their own tasks" on tasks for update using (auth.uid() = user_id);

-- 6. Task steps
create table if not exists task_steps (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references tasks(id) on delete cascade,
  parent_step_id uuid references task_steps(id) on delete cascade,
  depth_level integer not null default 0,
  sequence_no integer not null,
  step_text text not null,
  is_optional boolean not null default false,
  is_minimum_path boolean not null default false,
  completion_status text not null default 'pending' check (completion_status in ('pending', 'active', 'completed', 'skipped', 'paused')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table task_steps enable row level security;
drop policy if exists "Users can view their own task steps" on task_steps;
drop policy if exists "Users can insert their own task steps" on task_steps;
drop policy if exists "Users can update their own task steps" on task_steps;
create policy "Users can view their own task steps" on task_steps for select using (exists (select 1 from tasks where tasks.id = task_steps.task_id and tasks.user_id = auth.uid()));
create policy "Users can insert their own task steps" on task_steps for insert with check (exists (select 1 from tasks where tasks.id = task_steps.task_id and tasks.user_id = auth.uid()));
create policy "Users can update their own task steps" on task_steps for update using (exists (select 1 from tasks where tasks.id = task_steps.task_id and tasks.user_id = auth.uid()));

-- 7. Progress logs
create table if not exists progress_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users_profile(id) on delete cascade,
  task_id uuid references tasks(id) on delete cascade,
  step_id uuid references task_steps(id) on delete cascade,
  event_type text not null,
  metadata jsonb not null default '{}',
  created_at timestamptz not null default now()
);
alter table progress_logs enable row level security;
drop policy if exists "Users can view their own progress logs" on progress_logs;
drop policy if exists "Users can insert their own progress logs" on progress_logs;
create policy "Users can view their own progress logs" on progress_logs for select using (auth.uid() = user_id);
create policy "Users can insert their own progress logs" on progress_logs for insert with check (auth.uid() = user_id);

-- 8. Indexes
create index if not exists idx_tasks_user_id on tasks(user_id);
create index if not exists idx_tasks_status on tasks(status);
create index if not exists idx_task_steps_task_id on task_steps(task_id);
create index if not exists idx_task_steps_parent_step_id on task_steps(parent_step_id);
create index if not exists idx_progress_logs_user_id on progress_logs(user_id);
create index if not exists idx_progress_logs_task_id on progress_logs(task_id);

-- 9. Avatar config
create table if not exists user_avatar_config (
  user_id uuid primary key references users_profile(id) on delete cascade,
  avatar_style text not null default 'calm_orb',
  avatar_palette text not null default 'soft',
  accessory_config jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table user_avatar_config enable row level security;
drop policy if exists "user_avatar_config_self_all" on user_avatar_config;
create policy "user_avatar_config_self_all" on user_avatar_config
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- 10. Branding / pronunciation tables
create table if not exists pronunciation_defaults (
  locale_code text primary key,
  pronunciation_key text not null
);

create table if not exists reward_phrase_catalogue (
  id uuid primary key default gen_random_uuid(),
  phrase_type text not null,
  phrase_text text not null,
  is_active boolean not null default true
);

-- 11. Skin packs
create table if not exists skin_packs (
  id uuid primary key default gen_random_uuid(),
  skin_key text not null unique,
  title text not null,
  tier text not null default 'premium' check (tier in ('free','premium','seasonal')),
  is_active boolean not null default true
);

create table if not exists user_skin_unlocks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users_profile(id) on delete cascade,
  skin_pack_id uuid not null references skin_packs(id) on delete cascade,
  unlocked_at timestamptz not null default now(),
  unique(user_id, skin_pack_id)
);

-- 12. Side Quests
create table if not exists side_quests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users_profile(id) on delete cascade,
  task_id uuid references tasks(id) on delete cascade,
  routine_id uuid,
  title text not null,
  quest_type text not null,
  reward_xp integer not null default 50,
  status text not null default 'available' check (status in ('available', 'accepted', 'completed', 'dismissed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table side_quests enable row level security;
create policy "Users can view their own side quests" on side_quests for select using (auth.uid() = user_id);
create policy "Users can insert their own side quests" on side_quests for insert with check (auth.uid() = user_id);
create policy "Users can update their own side quests" on side_quests for update using (auth.uid() = user_id);

-- 13. Rewards
create table if not exists rewards (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users_profile(id) on delete cascade,
  reward_type text not null,
  reward_key text not null,
  amount integer not null default 0,
  source_type text,
  source_id uuid,
  created_at timestamptz not null default now()
);
alter table rewards enable row level security;
create policy "Users can view their own rewards" on rewards for select using (auth.uid() = user_id);
create policy "Users can insert their own rewards" on rewards for insert with check (auth.uid() = user_id);

-- 14. Routines
create table if not exists routines (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users_profile(id) on delete cascade,
  title text not null,
  age_band text not null,
  is_template boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table routines enable row level security;
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
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table routine_steps enable row level security;
create policy "Users can view their own routine steps" on routine_steps for select using (exists (select 1 from routines where routines.id = routine_steps.routine_id and routines.user_id = auth.uid()));
create policy "Users can insert their own routine steps" on routine_steps for insert with check (exists (select 1 from routines where routines.id = routine_steps.routine_id and routines.user_id = auth.uid()));
create policy "Users can update their own routine steps" on routine_steps for update using (exists (select 1 from routines where routines.id = routine_steps.routine_id and routines.user_id = auth.uid()));
