-- Create users_profile table first (extends auth.users)
create table if not exists users_profile (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  display_name text,
  age_band text default 'teen',
  default_mode text not null default 'audhd',
  voice_enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Enable RLS on users_profile
alter table users_profile enable row level security;

-- Drop existing policies if they exist, then recreate
drop policy if exists "Users can view their own profile" on users_profile;
drop policy if exists "Users can insert their own profile" on users_profile;
drop policy if exists "Users can update their own profile" on users_profile;

-- RLS policies for users_profile
create policy "Users can view their own profile" on users_profile
  for select using (auth.uid() = id);

create policy "Users can insert their own profile" on users_profile
  for insert with check (auth.uid() = id);

create policy "Users can update their own profile" on users_profile
  for update using (auth.uid() = id);

-- Trigger to automatically create profile on user signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.users_profile (id, email, display_name)
  values (new.id, new.email, new.raw_user_meta_data->>'display_name');
  return new;
end;
$$ language plpgsql security definer;

-- Trigger on auth.users
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Core task management tables
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

create table if not exists progress_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users_profile(id) on delete cascade,
  task_id uuid not null references tasks(id) on delete cascade,
  step_id uuid references task_steps(id) on delete cascade,
  event_type text not null,
  metadata jsonb not null default '{}',
  created_at timestamptz not null default now()
);

-- Indexes for performance
create index if not exists idx_tasks_user_id on tasks(user_id);
create index if not exists idx_tasks_status on tasks(status);
create index if not exists idx_task_steps_task_id on task_steps(task_id);
create index if not exists idx_task_steps_parent_step_id on task_steps(parent_step_id);
create index if not exists idx_progress_logs_user_id on progress_logs(user_id);
create index if not exists idx_progress_logs_task_id on progress_logs(task_id);

create table if not exists assistant_identity_settings (
  user_id uuid primary key references users_profile(id) on delete cascade,
  assistant_display_name text not null default 'Dope-i',
  pronunciation_key text not null default 'dope_ee',
  updated_at timestamptz not null default now()
);

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

-- Row Level Security
alter table tasks enable row level security;
alter table task_steps enable row level security;
alter table progress_logs enable row level security;
alter table assistant_identity_settings enable row level security;
alter table sensory_settings enable row level security;

-- Drop existing policies if they exist
drop policy if exists "Users can view their own tasks" on tasks;
drop policy if exists "Users can insert their own tasks" on tasks;
drop policy if exists "Users can update their own tasks" on tasks;
drop policy if exists "Users can view their own task steps" on task_steps;
drop policy if exists "Users can insert their own task steps" on task_steps;
drop policy if exists "Users can update their own task steps" on task_steps;
drop policy if exists "Users can view their own progress logs" on progress_logs;
drop policy if exists "Users can insert their own progress logs" on progress_logs;
drop policy if exists "Users can view their own assistant identity settings" on assistant_identity_settings;
drop policy if exists "Users can insert their own assistant identity settings" on assistant_identity_settings;
drop policy if exists "Users can update their own assistant identity settings" on assistant_identity_settings;
drop policy if exists "Users can delete their own assistant identity settings" on assistant_identity_settings;
drop policy if exists "Users can view their own sensory settings" on sensory_settings;
drop policy if exists "Users can insert their own sensory settings" on sensory_settings;
drop policy if exists "Users can update their own sensory settings" on sensory_settings;
drop policy if exists "Users can delete their own sensory settings" on sensory_settings;

-- RLS Policies
create policy "Users can view their own tasks" on tasks
  for select using (auth.uid() = user_id);

create policy "Users can insert their own tasks" on tasks
  for insert with check (auth.uid() = user_id);

create policy "Users can update their own tasks" on tasks
  for update using (auth.uid() = user_id);

create policy "Users can view their own task steps" on task_steps
  for select using (
    exists (
      select 1 from tasks
      where tasks.id = task_steps.task_id
      and tasks.user_id = auth.uid()
    )
  );

create policy "Users can insert their own task steps" on task_steps
  for insert with check (
    exists (
      select 1 from tasks
      where tasks.id = task_steps.task_id
      and tasks.user_id = auth.uid()
    )
  );

create policy "Users can update their own task steps" on task_steps
  for update using (
    exists (
      select 1 from tasks
      where tasks.id = task_steps.task_id
      and tasks.user_id = auth.uid()
    )
  );

create policy "Users can view their own progress logs" on progress_logs
  for select using (auth.uid() = user_id);

create policy "Users can insert their own progress logs" on progress_logs
  for insert with check (auth.uid() = user_id);

create policy "Users can view their own assistant identity settings" on assistant_identity_settings
  for select using (auth.uid() = user_id);

create policy "Users can insert their own assistant identity settings" on assistant_identity_settings
  for insert with check (auth.uid() = user_id);

create policy "Users can update their own assistant identity settings" on assistant_identity_settings
  for update using (auth.uid() = user_id);

create policy "Users can delete their own assistant identity settings" on assistant_identity_settings
  for delete using (auth.uid() = user_id);

create policy "Users can view their own sensory settings" on sensory_settings
  for select using (auth.uid() = user_id);

create policy "Users can insert their own sensory settings" on sensory_settings
  for insert with check (auth.uid() = user_id);

create policy "Users can update their own sensory settings" on sensory_settings
  for update using (auth.uid() = user_id);

create policy "Users can delete their own sensory settings" on sensory_settings
  for delete using (auth.uid() = user_id);