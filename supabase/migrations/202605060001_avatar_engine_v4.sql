create table if not exists public.avatar_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  config jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.avatar_inventory (
  user_id uuid primary key references auth.users(id) on delete cascade,
  owned_item_ids text[] not null default '{}'::text[],
  cached_pack_ids text[] not null default '{}'::text[],
  last_synced_at timestamptz,
  updated_at timestamptz not null default now()
);

create table if not exists public.avatar_purchases (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  item_id text not null,
  purchase_source text not null default 'app',
  purchased_at timestamptz not null default now(),
  unique (user_id, item_id)
);

create table if not exists public.avatar_uploads (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  storage_path text not null,
  consent_version text not null,
  created_at timestamptz not null default now()
);

alter table public.avatar_profiles enable row level security;
alter table public.avatar_inventory enable row level security;
alter table public.avatar_purchases enable row level security;
alter table public.avatar_uploads enable row level security;

create policy "avatar_profiles_select_own"
  on public.avatar_profiles for select
  using (auth.uid() = user_id);

create policy "avatar_profiles_upsert_own"
  on public.avatar_profiles for insert
  with check (auth.uid() = user_id);

create policy "avatar_profiles_update_own"
  on public.avatar_profiles for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "avatar_inventory_select_own"
  on public.avatar_inventory for select
  using (auth.uid() = user_id);

create policy "avatar_inventory_insert_own"
  on public.avatar_inventory for insert
  with check (auth.uid() = user_id);

create policy "avatar_inventory_update_own"
  on public.avatar_inventory for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "avatar_purchases_select_own"
  on public.avatar_purchases for select
  using (auth.uid() = user_id);

create policy "avatar_purchases_insert_own"
  on public.avatar_purchases for insert
  with check (auth.uid() = user_id);

create policy "avatar_uploads_select_own"
  on public.avatar_uploads for select
  using (auth.uid() = user_id);

create policy "avatar_uploads_insert_own"
  on public.avatar_uploads for insert
  with check (auth.uid() = user_id);
