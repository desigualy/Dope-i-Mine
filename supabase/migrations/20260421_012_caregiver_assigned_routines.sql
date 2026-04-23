create table if not exists caregiver_assigned_routines (
  id uuid primary key default gen_random_uuid(),
  caregiver_user_id uuid not null references users_profile(id) on delete cascade,
  target_user_id uuid not null references users_profile(id) on delete cascade,
  routine_id uuid not null references routines(id) on delete cascade,
  status text not null default 'active' check (status in ('active','completed','archived')),
  assigned_at timestamptz not null default now(),
  unique(caregiver_user_id, target_user_id, routine_id)
);
