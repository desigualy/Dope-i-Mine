-- Persist concrete installed platform TTS voice selections per user.
-- This migration is intentionally additive so existing deployments can apply it
-- without replaying the original voice settings migration.

alter table public.user_voice_settings
  add column if not exists platform_voice_name text,
  add column if not exists platform_voice_locale text,
  add column if not exists offline_voice_id text;