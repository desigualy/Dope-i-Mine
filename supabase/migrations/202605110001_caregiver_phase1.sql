-- Caregiver System: Phases C1-C5
-- Key Principle: Support, not surveillance.

-- 1. Relationships (Phase C1)
do $$
begin
  if not exists (select 1 from pg_type where typname = 'caregiver_role') then
    create type public.caregiver_role as enum ('caregiver', 'overseer', 'monitor');
  end if;
  if not exists (select 1 from pg_type where typname = 'caregiver_relationship_status') then
    create type public.caregiver_relationship_status as enum ('pending', 'accepted', 'declined', 'blocked', 'revoked');
  end if;
end $$;

create table if not exists public.caregiver_relationships (
  id uuid primary key default gen_random_uuid(),
  caregiver_user_id uuid not null references public.users_profile(id) on delete cascade,
  supported_user_id uuid not null references public.users_profile(id) on delete cascade,
  role public.caregiver_role not null default 'caregiver',
  status public.caregiver_relationship_status not null default 'pending',
  relationship_label text null,
  created_at timestamptz not null default now(),
  accepted_at timestamptz null,
  revoked_at timestamptz null,
  unique(caregiver_user_id, supported_user_id)
);

alter table public.caregiver_relationships enable row level security;

-- 2. Permissions (Phase C1)
create table if not exists public.caregiver_permissions (
  id uuid primary key default gen_random_uuid(),
  relationship_id uuid not null references public.caregiver_relationships(id) on delete cascade unique,
  
  -- View permissions
  can_view_task_titles boolean not null default true,
  can_view_task_steps boolean not null default false,
  can_view_progress boolean not null default true,
  can_view_missed_routines boolean not null default true,
  can_view_body_double_summaries boolean not null default true,
  can_view_safety_alerts boolean not null default true,
  
  -- Action permissions
  can_assign_tasks boolean not null default false,
  can_assign_routines boolean not null default false,
  can_set_reminders boolean not null default false,
  can_suggest_side_quests boolean not null default false,
  can_invite_body_double boolean not null default false,
  can_approve_random_body_double boolean not null default false,
  can_archive_assignments boolean not null default false,
  
  -- Restriction permissions
  only_view_assigned_tasks boolean not null default false,
  only_view_caregiver_routines boolean not null default false,
  only_view_summaries boolean not null default false,
  support_hours_json jsonb null, -- e.g. {"mon": ["09:00", "17:00"], ...}
  
  updated_at timestamptz not null default now()
);

alter table public.caregiver_permissions enable row level security;

-- 3. Assigned Tasks (Phase C2)
do $$
begin
  if not exists (select 1 from pg_type where typname = 'caregiver_task_status') then
    create type public.caregiver_task_status as enum ('suggested', 'accepted', 'active', 'completed', 'declined', 'archived');
  end if;
end $$;

create table if not exists public.caregiver_assigned_tasks (
  id uuid primary key default gen_random_uuid(),
  caregiver_user_id uuid not null references public.users_profile(id) on delete cascade,
  target_user_id uuid not null references public.users_profile(id) on delete cascade,
  task_id uuid not null references public.tasks(id) on delete cascade,
  status public.caregiver_task_status not null default 'suggested',
  due_at timestamptz null,
  visibility_level text not null default 'standard', -- standard | private
  assigned_at timestamptz not null default now(),
  accepted_at timestamptz null,
  completed_at timestamptz null,
  created_at timestamptz not null default now()
);

alter table public.caregiver_assigned_tasks enable row level security;

-- 4. Assigned Routines (Phase C3)
-- We'll migrate the existing table if it exists or create it
drop table if exists public.caregiver_assigned_routines cascade;

create table public.caregiver_assigned_routines (
  id uuid primary key default gen_random_uuid(),
  caregiver_user_id uuid not null references public.users_profile(id) on delete cascade,
  target_user_id uuid not null references public.users_profile(id) on delete cascade,
  routine_id uuid not null references public.routines(id) on delete cascade,
  status text not null default 'active' check (status in ('active', 'completed', 'archived')),
  assigned_at timestamptz not null default now(),
  unique(caregiver_user_id, target_user_id, routine_id)
);

alter table public.caregiver_assigned_routines enable row level security;

-- 5. Check-ins (Phase C1/C4)
create table if not exists public.caregiver_check_ins (
  id uuid primary key default gen_random_uuid(),
  relationship_id uuid not null references public.caregiver_relationships(id) on delete cascade,
  sender_id uuid not null references auth.users(id) on delete cascade,
  receiver_id uuid not null references auth.users(id) on delete cascade,
  message text not null,
  check_in_type text not null default 'encouragement', -- encouragement | question | nudge
  created_at timestamptz not null default now(),
  read_at timestamptz null
);

alter table public.caregiver_check_ins enable row level security;

-- 6. Alerts (Phase C3/C4)
create table if not exists public.caregiver_alerts (
  id uuid primary key default gen_random_uuid(),
  relationship_id uuid not null references public.caregiver_relationships(id) on delete cascade,
  alert_type text not null, -- missed_routine | safety_report | emergency
  severity text not null default 'info', -- info | warning | critical
  title text not null,
  body text null,
  created_at timestamptz not null default now(),
  acknowledged_at timestamptz null
);

alter table public.caregiver_alerts enable row level security;

-- 7. RLS Policies

-- Relationships: visible to both parties
create policy "caregiver_relationships_visibility"
  on public.caregiver_relationships for select
  using (auth.uid() = caregiver_user_id or auth.uid() = supported_user_id);

create policy "caregiver_relationships_insert"
  on public.caregiver_relationships for insert
  with check (auth.uid() = caregiver_user_id or auth.uid() = supported_user_id);

create policy "caregiver_relationships_update"
  on public.caregiver_relationships for update
  using (auth.uid() = caregiver_user_id or auth.uid() = supported_user_id);

-- Permissions: visible to both, but only supported user or overseer can update
create policy "caregiver_permissions_visibility"
  on public.caregiver_permissions for select
  using (exists (
    select 1 from public.caregiver_relationships r
    where r.id = relationship_id
      and (auth.uid() = r.caregiver_user_id or auth.uid() = r.supported_user_id)
  ));

create policy "caregiver_permissions_update"
  on public.caregiver_permissions for update
  using (exists (
    select 1 from public.caregiver_relationships r
    where r.id = relationship_id
      and (
        auth.uid() = r.supported_user_id 
        or (auth.uid() = r.caregiver_user_id and r.role = 'overseer')
      )
  ));

-- Assigned Tasks Policies
create policy "caregiver_tasks_visibility"
  on public.caregiver_assigned_tasks for select
  using (auth.uid() = caregiver_user_id or auth.uid() = target_user_id);

create policy "caregiver_tasks_insert"
  on public.caregiver_assigned_tasks for insert
  with check (auth.uid() = caregiver_user_id);

-- 8. Functions & Triggers

-- Automatically create permissions record when relationship is created
create or replace function public.on_caregiver_relationship_created()
returns trigger
language plpgsql
security definer
as $$
begin
  insert into public.caregiver_permissions (relationship_id)
  values (new.id);
  return new;
end;
$$;

create trigger caregiver_relationship_created_trigger
  after insert on public.caregiver_relationships
  for each row execute function public.on_caregiver_relationship_created();

-- 9. Migration of legacy links (Phase C1)
-- Check if caregiver_links exists and migrate data
do $$
begin
  if exists (select 1 from information_schema.tables where table_name = 'caregiver_links') then
    insert into public.caregiver_relationships (caregiver_user_id, supported_user_id, role, status, accepted_at)
    select caregiver_user_id, primary_user_id, 'overseer', 'accepted', created_at
    from public.caregiver_links
    on conflict do nothing;
  end if;
end $$;
