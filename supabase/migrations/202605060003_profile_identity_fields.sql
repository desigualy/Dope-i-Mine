alter table public.users_profile
  add column if not exists sex_at_birth text,
  add column if not exists gender_identity text,
  add column if not exists pronouns text,
  add column if not exists custom_pronouns text;
