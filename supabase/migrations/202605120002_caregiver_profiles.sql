-- Distinguish standard users from caregivers at signup and store caregiver details.

alter table public.users_profile
  add column if not exists account_type text not null default 'user'
  check (account_type in ('user', 'caregiver'));

create table if not exists public.caregiver_profiles (
  user_id uuid primary key references public.users_profile(id) on delete cascade,
  contact_email text,
  display_name text,
  organisation_name text,
  relationship_to_supported text,
  verification_status text not null default 'unverified'
    check (verification_status in ('unverified', 'pending', 'verified', 'rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.caregiver_profiles enable row level security;

drop policy if exists "caregiver_profiles_owner_select" on public.caregiver_profiles;
create policy "caregiver_profiles_owner_select"
  on public.caregiver_profiles for select
  using (auth.uid() = user_id);

drop policy if exists "caregiver_profiles_owner_insert" on public.caregiver_profiles;
create policy "caregiver_profiles_owner_insert"
  on public.caregiver_profiles for insert
  with check (auth.uid() = user_id);

drop policy if exists "caregiver_profiles_owner_update" on public.caregiver_profiles;
create policy "caregiver_profiles_owner_update"
  on public.caregiver_profiles for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_account_type text := coalesce(new.raw_user_meta_data->>'account_type', 'user');
begin
  if v_account_type not in ('user', 'caregiver') then
    v_account_type := 'user';
  end if;

  insert into public.users_profile (id, email, display_name, account_type)
  values (new.id, new.email, new.raw_user_meta_data->>'display_name', v_account_type)
  on conflict (id) do update
    set email = excluded.email,
        account_type = excluded.account_type,
        updated_at = now();

  if v_account_type = 'caregiver' then
    insert into public.caregiver_profiles (user_id, contact_email, display_name)
    values (new.id, new.email, new.raw_user_meta_data->>'display_name')
    on conflict (user_id) do update
      set contact_email = excluded.contact_email,
          display_name = excluded.display_name,
          updated_at = now();
  end if;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();