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
