create table if not exists users_profile (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  display_name text,
  age_band text default 'teen',
  default_mode text not null default 'audhd',
  voice_enabled boolean not null default true,
  onboarding_completed boolean not null default false,
  onboarding_completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists voice_profiles (
  id uuid primary key default gen_random_uuid(),
  provider text not null,
  label text not null,
  accent text,
  pace text,
  warmth text,
  firmness text,
  tone_preset text unique
);

create table if not exists routines (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users_profile(id) on delete cascade,
  title text not null,
  cadence text,
  created_at timestamptz not null default now()
);

insert into voice_profiles (provider, label, accent, pace, warmth, firmness, tone_preset)
values
  ('system', 'Calm Guide UK', 'UK', 'slow', 'high', 'low', 'calm_guide'),
  ('system', 'Practical Coach UK', 'UK', 'normal', 'medium', 'high', 'practical_coach'),
  ('system', 'Gentle Companion US', 'US', 'slow', 'high', 'low', 'gentle_companion'),
  ('system', 'Focus Drill UK', 'UK', 'normal', 'low', 'high', 'focus_drill'),
  ('system', 'Friendly Peer UK', 'UK', 'normal', 'medium', 'medium', 'friendly_peer')
on conflict do nothing;
