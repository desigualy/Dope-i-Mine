-- Voice profile catalogue + user voice settings for live TTS/STT configuration.
-- This migration intentionally uses deterministic text ids so the Flutter app,
-- tests, and live DB E2E checks can all refer to the same profiles.

alter table if exists public.voice_profiles
  alter column id type text using id::text;

create table if not exists public.voice_profiles (
  id text primary key,
  provider text not null default 'system',
  label text not null,
  accent text not null check (accent in ('UK', 'US')),
  gender text not null check (gender in ('female', 'male', 'neutral')),
  locale_id text not null,
  pace text not null default 'normal',
  warmth text not null default 'medium',
  firmness text not null default 'medium',
  tone_preset text unique,
  platform_voice_name text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.voice_profiles
  add column if not exists gender text not null default 'neutral',
  add column if not exists locale_id text,
  add column if not exists platform_voice_name text,
  add column if not exists is_active boolean not null default true,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

update public.voice_profiles
set locale_id = case when accent = 'US' then 'en-US' else 'en-GB' end
where locale_id is null;

alter table public.voice_profiles
  alter column locale_id set not null;

create table if not exists public.user_voice_settings (
  user_id uuid primary key references public.users_profile(id) on delete cascade,
  active_voice_profile_id text references public.voice_profiles(id),
  locale_id text,
  speech_rate numeric not null default 1.0,
  auto_read_steps boolean not null default false,
  auto_read_sidequests boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.user_voice_settings
  add column if not exists active_voice_profile_id text references public.voice_profiles(id),
  add column if not exists locale_id text,
  add column if not exists speech_rate numeric not null default 1.0,
  add column if not exists auto_read_steps boolean not null default false,
  add column if not exists auto_read_sidequests boolean not null default false,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

insert into public.voice_profiles
  (id, provider, label, accent, gender, locale_id, pace, warmth, firmness, tone_preset, is_active)
values
  ('uk_female_calm_guide', 'system', 'UK Female — Calm Guide', 'UK', 'female', 'en-GB', 'slow', 'high', 'low', 'uk_female_calm_guide', true),
  ('uk_female_bright_coach', 'system', 'UK Female — Bright Coach', 'UK', 'female', 'en-GB', 'bright', 'medium', 'medium', 'uk_female_bright_coach', true),
  ('uk_male_steady_guide', 'system', 'UK Male — Steady Guide', 'UK', 'male', 'en-GB', 'normal', 'medium', 'medium', 'uk_male_steady_guide', true),
  ('uk_male_focus_coach', 'system', 'UK Male — Focus Coach', 'UK', 'male', 'en-GB', 'normal', 'low', 'high', 'uk_male_focus_coach', true),
  ('us_female_gentle_companion', 'system', 'US Female — Gentle Companion', 'US', 'female', 'en-US', 'slow', 'high', 'low', 'us_female_gentle_companion', true),
  ('us_female_practical_coach', 'system', 'US Female — Practical Coach', 'US', 'female', 'en-US', 'normal', 'medium', 'high', 'us_female_practical_coach', true),
  ('us_male_warm_mentor', 'system', 'US Male — Warm Mentor', 'US', 'male', 'en-US', 'normal', 'high', 'medium', 'us_male_warm_mentor', true),
  ('us_male_direct_coach', 'system', 'US Male — Direct Coach', 'US', 'male', 'en-US', 'bright', 'low', 'high', 'us_male_direct_coach', true)
on conflict (id) do update set
  provider = excluded.provider,
  label = excluded.label,
  accent = excluded.accent,
  gender = excluded.gender,
  locale_id = excluded.locale_id,
  pace = excluded.pace,
  warmth = excluded.warmth,
  firmness = excluded.firmness,
  tone_preset = excluded.tone_preset,
  is_active = excluded.is_active,
  updated_at = now();

alter table public.voice_profiles enable row level security;
alter table public.user_voice_settings enable row level security;

drop policy if exists "Anyone authenticated can read active voice profiles" on public.voice_profiles;
create policy "Anyone authenticated can read active voice profiles" on public.voice_profiles
  for select using (auth.role() = 'authenticated' and is_active = true);

drop policy if exists "Users can read own voice settings" on public.user_voice_settings;
create policy "Users can read own voice settings" on public.user_voice_settings
  for select using (auth.uid() = user_id);

drop policy if exists "Users can insert own voice settings" on public.user_voice_settings;
create policy "Users can insert own voice settings" on public.user_voice_settings
  for insert with check (auth.uid() = user_id);

drop policy if exists "Users can update own voice settings" on public.user_voice_settings;
create policy "Users can update own voice settings" on public.user_voice_settings
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);