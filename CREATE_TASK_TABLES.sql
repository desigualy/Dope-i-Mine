-- ============================================================================
-- SUPABASE PRODUCTION SCHEMA - Task Management System
-- ============================================================================

-- Drop tables if they exist (in correct order due to foreign keys)
drop table if exists progress_logs cascade;
drop table if exists task_steps cascade;
drop table if exists tasks cascade;
drop table if exists users_profile cascade;

-- ============================================================================
-- 1. USERS PROFILE TABLE
-- ============================================================================
create table users_profile (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  display_name text,
  age_band text default 'teen',
  default_mode text not null default 'audhd',
  voice_enabled boolean not null default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table users_profile enable row level security;

-- Profile policies
create policy "users_profile_select" on users_profile
  for select using (auth.uid() = id);

create policy "users_profile_insert" on users_profile
  for insert with check (auth.uid() = id);

create policy "users_profile_update" on users_profile
  for update using (auth.uid() = id);

-- Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.users_profile (id, email, display_name)
  values (new.id, new.email, new.raw_user_meta_data->>'display_name')
  on conflict(id) do nothing;
  return new;
end;
$$ language plpgsql security definer set search_path = public;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function public.handle_new_user();

-- ============================================================================
-- 2. TASKS TABLE
-- ============================================================================
create table tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users_profile(id) on delete cascade,
  source_text text not null,
  normalized_title text not null,
  category text default 'general',
  status text not null default 'active' check (status in ('active', 'completed', 'paused', 'cancelled')),
  mode_used text not null default 'audhd',
  energy_level text not null default 'medium',
  stress_level text not null default 'moderate',
  time_available text not null default 'fifteen_minutes',
  effort_band text not null default 'medium',
  estimated_minutes integer default 15,
  state_snapshot jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table tasks enable row level security;

create policy "tasks_select" on tasks
  for select using (auth.uid() = user_id);

create policy "tasks_insert" on tasks
  for insert with check (auth.uid() = user_id);

create policy "tasks_update" on tasks
  for update using (auth.uid() = user_id);

create policy "tasks_delete" on tasks
  for delete using (auth.uid() = user_id);

create index idx_tasks_user_id on tasks(user_id);
create index idx_tasks_status on tasks(status);
create index idx_tasks_created_at on tasks(created_at);

-- ============================================================================
-- 3. TASK STEPS TABLE
-- ============================================================================
create table task_steps (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references tasks(id) on delete cascade,
  parent_step_id uuid references task_steps(id) on delete cascade,
  depth_level integer default 0,
  sequence_no integer not null,
  step_text text not null,
  is_optional boolean default false,
  is_minimum_path boolean default false,
  completion_status text not null default 'pending' check (completion_status in ('pending', 'active', 'completed', 'skipped', 'paused')),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table task_steps enable row level security;

create policy "task_steps_select" on task_steps
  for select using (
    exists (
      select 1 from tasks
      where tasks.id = task_steps.task_id
      and tasks.user_id = auth.uid()
    )
  );

create policy "task_steps_insert" on task_steps
  for insert with check (
    exists (
      select 1 from tasks
      where tasks.id = task_steps.task_id
      and tasks.user_id = auth.uid()
    )
  );

create policy "task_steps_update" on task_steps
  for update using (
    exists (
      select 1 from tasks
      where tasks.id = task_steps.task_id
      and tasks.user_id = auth.uid()
    )
  );

create policy "task_steps_delete" on task_steps
  for delete using (
    exists (
      select 1 from tasks
      where tasks.id = task_steps.task_id
      and tasks.user_id = auth.uid()
    )
  );

create index idx_task_steps_task_id on task_steps(task_id);
create index idx_task_steps_parent_step_id on task_steps(parent_step_id);
create index idx_task_steps_status on task_steps(completion_status);

-- ============================================================================
-- 4. PROGRESS LOGS TABLE
-- ============================================================================
create table progress_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users_profile(id) on delete cascade,
  task_id uuid not null references tasks(id) on delete cascade,
  step_id uuid references task_steps(id) on delete set null,
  event_type text not null,
  metadata jsonb default '{}',
  created_at timestamptz default now()
);

alter table progress_logs enable row level security;

create policy "progress_logs_select" on progress_logs
  for select using (auth.uid() = user_id);

create policy "progress_logs_insert" on progress_logs
  for insert with check (auth.uid() = user_id);

create index idx_progress_logs_user_id on progress_logs(user_id);
create index idx_progress_logs_task_id on progress_logs(task_id);
create index idx_progress_logs_created_at on progress_logs(created_at);

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================

-- ============================================================================
-- 5. ASSISTANT IDENTITY SETTINGS TABLE
-- ============================================================================
create table assistant_identity_settings (
  user_id uuid primary key references users_profile(id) on delete cascade,
  assistant_display_name text not null default 'Dope-i',
  pronunciation_key text not null default 'dope_ee',
  updated_at timestamptz not null default now()
);

alter table assistant_identity_settings enable row level security;

create policy "assistant_identity_settings_select" on assistant_identity_settings
  for select using (auth.uid() = user_id);

create policy "assistant_identity_settings_insert" on assistant_identity_settings
  for insert with check (auth.uid() = user_id);

create policy "assistant_identity_settings_update" on assistant_identity_settings
  for update using (auth.uid() = user_id);

create policy "assistant_identity_settings_delete" on assistant_identity_settings
  for delete using (auth.uid() = user_id);

-- ============================================================================
-- 6. SENSORY SETTINGS TABLE
-- ============================================================================
create table sensory_settings (
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

create policy "sensory_settings_select" on sensory_settings
  for select using (auth.uid() = user_id);

create policy "sensory_settings_insert" on sensory_settings
  for insert with check (auth.uid() = user_id);

create policy "sensory_settings_update" on sensory_settings
  for update using (auth.uid() = user_id);

create policy "sensory_settings_delete" on sensory_settings
  for delete using (auth.uid() = user_id);

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================