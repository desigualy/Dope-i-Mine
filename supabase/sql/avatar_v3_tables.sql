create table if not exists avatar_v3_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  profile_json jsonb not null,
  sync_version bigint not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id)
);

create table if not exists avatar_v3_inventory (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  owned_asset_ids jsonb not null default '[]'::jsonb,
  owned_pack_ids jsonb not null default '["starter_pack"]'::jsonb,
  updated_at timestamptz not null default now(),
  unique(user_id)
);

create table if not exists avatar_v3_asset_packs (
  id text primary key,
  title text not null,
  description text,
  version int not null default 1,
  price_tier text not null default 'free',
  manifest_json jsonb not null,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists avatar_v3_entitlements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  asset_id text,
  pack_id text,
  source text not null,
  created_at timestamptz not null default now(),
  unique(user_id, asset_id, pack_id)
);

alter table avatar_v3_profiles enable row level security;
alter table avatar_v3_inventory enable row level security;
alter table avatar_v3_entitlements enable row level security;

create policy if not exists avatar_v3_profiles_own_rows
on avatar_v3_profiles for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy if not exists avatar_v3_inventory_own_rows
on avatar_v3_inventory for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy if not exists avatar_v3_entitlements_own_rows
on avatar_v3_entitlements for select
using (auth.uid() = user_id);
