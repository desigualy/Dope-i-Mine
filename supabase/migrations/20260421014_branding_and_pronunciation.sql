create table if not exists assistant_identity_settings (
  user_id uuid primary key references users_profile(id) on delete cascade,
  assistant_display_name text not null default 'Dope-i',
  pronunciation_key text not null default 'dope_ee',
  updated_at timestamptz not null default now()
);

create table if not exists pronunciation_defaults (
  locale_code text primary key,
  pronunciation_key text not null
);

create table if not exists reward_phrase_catalogue (
  id uuid primary key default gen_random_uuid(),
  phrase_type text not null,
  phrase_text text not null,
  is_active boolean not null default true
);
