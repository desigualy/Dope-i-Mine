create table if not exists user_avatar_config (
  user_id uuid primary key references users_profile(id) on delete cascade,
  avatar_style text not null default 'calm_orb',
  avatar_palette text not null default 'soft',
  accessory_config jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
