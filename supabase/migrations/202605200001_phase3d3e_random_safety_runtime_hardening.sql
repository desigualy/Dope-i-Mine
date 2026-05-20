-- Phase 3D + 3E hardening: random body-double safety gate before matching runtime.
-- Idempotent by design. This migration tightens the advanced random runtime
-- without resetting data or weakening existing caregiver/body-double policies.

alter table public.body_double_queue drop constraint if exists body_double_queue_communication_mode_check;
alter table public.body_double_queue add constraint body_double_queue_communication_mode_check
  check (communication_mode in ('quiet', 'presetSignals', 'textOnly'));

alter table public.body_double_queue drop constraint if exists body_double_queue_minor_safety_check;
alter table public.body_double_queue add constraint body_double_queue_minor_safety_check
  check (
    age_band = 'adult'
    or (
      random_matching_enabled = true
      and guardian_approved = true
      and communication_mode in ('quiet', 'presetSignals')
    )
  );

alter table public.body_double_sessions drop constraint if exists body_double_sessions_random_mode_safe_check;
alter table public.body_double_sessions add constraint body_double_sessions_random_mode_safe_check
  check (mode <> 'random' or communication_mode in ('quiet', 'presetSignals', 'textOnly'));

create or replace function public.set_adult_random_body_double_settings(
  p_random_matching_enabled boolean,
  p_preset_signals_allowed boolean default true,
  p_quiet_mode_allowed boolean default true,
  p_text_allowed boolean default false,
  p_voice_allowed boolean default false
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_age_band text;
begin
  if v_user_id is null then raise exception 'Not authenticated'; end if;

  select public.normalize_body_double_age_band(age_band) into v_age_band
  from public.users_profile where id = v_user_id;

  if v_age_band <> 'adult' then
    raise exception 'Only adult users can manage their own random body double settings';
  end if;
  if p_preset_signals_allowed is not true and p_quiet_mode_allowed is not true then
    raise exception 'At least one safe random communication mode must remain enabled';
  end if;

  insert into public.body_double_random_safety_settings (
    user_id, random_matching_enabled, guardian_random_approved,
    preset_signals_allowed, quiet_mode_allowed, text_allowed, voice_allowed, updated_at
  ) values (
    v_user_id, p_random_matching_enabled, false,
    p_preset_signals_allowed, p_quiet_mode_allowed, p_text_allowed, false, now()
  )
  on conflict (user_id) do update set
    random_matching_enabled = excluded.random_matching_enabled,
    guardian_random_approved = false,
    guardian_approved_by = null,
    guardian_approved_at = null,
    preset_signals_allowed = excluded.preset_signals_allowed,
    quiet_mode_allowed = excluded.quiet_mode_allowed,
    text_allowed = excluded.text_allowed,
    voice_allowed = false,
    updated_at = now();

  insert into public.body_double_audit_events(actor_id, event_type, metadata)
  values (v_user_id, 'random_safety_settings_updated', jsonb_build_object(
    'random_matching_enabled', p_random_matching_enabled,
    'preset_signals_allowed', p_preset_signals_allowed,
    'quiet_mode_allowed', p_quiet_mode_allowed,
    'text_allowed', p_text_allowed,
    'voice_allowed', false,
    'voice_requested_but_disabled', coalesce(p_voice_allowed, false)
  ));
end;
$$;

create or replace function public.get_random_body_double_eligibility(p_user_id uuid default auth.uid())
returns table (
  user_id uuid,
  age_band text,
  random_matching_enabled boolean,
  guardian_approved boolean,
  preset_signals_allowed boolean,
  quiet_mode_allowed boolean,
  text_allowed boolean,
  voice_allowed boolean,
  can_enter_random_queue boolean
)
language sql
stable
security definer
set search_path = public
as $$
  select
    p.id as user_id,
    public.normalize_body_double_age_band(p.age_band) as age_band,
    coalesce(s.random_matching_enabled, false) as random_matching_enabled,
    coalesce(s.guardian_random_approved, false) as guardian_approved,
    coalesce(s.preset_signals_allowed, true) as preset_signals_allowed,
    coalesce(s.quiet_mode_allowed, true) as quiet_mode_allowed,
    coalesce(s.text_allowed, false) as text_allowed,
    false as voice_allowed,
    case
      when exists (
        select 1 from public.body_double_user_restrictions r
        where r.user_id = p.id
          and r.status = 'active'
          and r.restriction_type in ('random_suspended', 'body_double_suspended')
          and r.starts_at <= now()
          and (r.expires_at is null or r.expires_at > now())
      ) then false
      when public.normalize_body_double_age_band(p.age_band) = 'adult' then
        coalesce(s.random_matching_enabled, false)
      else
        coalesce(s.random_matching_enabled, false)
        and coalesce(s.guardian_random_approved, false)
    end as can_enter_random_queue
  from public.users_profile p
  left join public.body_double_random_safety_settings s on s.user_id = p.id
  where p.id = p_user_id
    and p_user_id = auth.uid();
$$;

create or replace function public.body_double_random_text_block_reason(p_body text)
returns text
language plpgsql
immutable
as $$
declare
  v_body text := lower(coalesce(p_body, ''));
begin
  if length(trim(coalesce(p_body, ''))) = 0 then return 'empty'; end if;
  if length(trim(p_body)) > 160 then return 'too_long'; end if;
  if v_body ~ '([[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}|\+?[0-9][0-9[:space:]().-]{7,}[0-9]|@[a-z0-9_.-]{3,}|\y(instagram|snapchat|tiktok|discord|whatsapp|telegram|facebook|fb|x handle)\y)' then return 'contact_info'; end if;
  if v_body ~ '(https?://|www\.|\.com\y|\.net\y|\.org\y|\.io\y)' then return 'link'; end if;
  if v_body ~ '\y(where do you live|your address|my address|meet me|location|postcode|post code|zip code|street address|come to my|near you|near me)\y|\y[a-z]{1,2}[0-9][a-z0-9]?[[:space:]]*[0-9][a-z]{2}\y' then return 'location_request'; end if;
  if v_body ~ '\y(sex|sexual|nude|kill yourself|kys|suicide|self[- ]?harm|fuck|shit|bitch|cunt)\y' then return 'unsafe_content'; end if;
  return null;
end;
$$;

create or replace function public.enter_random_body_double_queue(
  p_session_type text,
  p_task_category text default 'general',
  p_session_length_minutes integer default 25,
  p_communication_mode text default 'presetSignals',
  p_privacy_level text default 'titleOnly',
  p_language text default 'en',
  p_timezone text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_eligibility record;
  v_queue_id uuid;
  v_safe_privacy text;
begin
  update public.body_double_user_restrictions set status = 'expired', updated_at = now()
  where status = 'active' and expires_at is not null and expires_at <= now();

  if v_user_id is null then raise exception 'Not authenticated'; end if;
  select * into v_eligibility from public.get_random_body_double_eligibility(v_user_id) limit 1;
  if not found or v_eligibility.can_enter_random_queue is not true then
    raise exception 'Random body double is not enabled for this user';
  end if;
  if p_communication_mode not in ('quiet', 'presetSignals', 'textOnly') then
    raise exception 'Random body double supports quiet, presetSignals, or adult-only textOnly';
  end if;
  if p_communication_mode = 'quiet' and v_eligibility.quiet_mode_allowed is not true then
    raise exception 'Quiet random body double is not enabled for this user';
  end if;
  if p_communication_mode = 'presetSignals' and v_eligibility.preset_signals_allowed is not true then
    raise exception 'Preset signals are not enabled for this user';
  end if;
  if p_communication_mode = 'textOnly' and (v_eligibility.age_band <> 'adult' or v_eligibility.text_allowed is not true) then
    raise exception 'Random text is adult-only and must be explicitly enabled';
  end if;
  if v_eligibility.age_band <> 'adult' and p_communication_mode not in ('quiet', 'presetSignals') then
    raise exception 'Minors can only use quiet or preset-signal random body doubling';
  end if;

  v_safe_privacy := case when p_privacy_level = 'private' then 'private' else 'titleOnly' end;
  update public.body_double_queue set status = 'cancelled', updated_at = now()
  where user_id = v_user_id and status = 'waiting';

  insert into public.body_double_queue (
    user_id, session_type, task_category, session_length_minutes, communication_mode,
    privacy_level, status, age_band, guardian_approved, random_matching_enabled,
    language, timezone, expires_at
  ) values (
    v_user_id, p_session_type, coalesce(nullif(trim(p_task_category), ''), 'general'),
    greatest(5, least(coalesce(p_session_length_minutes, 25), 60)), p_communication_mode,
    v_safe_privacy, 'waiting', v_eligibility.age_band, v_eligibility.guardian_approved,
    true, coalesce(nullif(trim(p_language), ''), 'en'), p_timezone, now() + interval '10 minutes'
  ) returning id into v_queue_id;

  insert into public.body_double_audit_events(actor_id, queue_id, event_type, metadata)
  values (v_user_id, v_queue_id, 'random_queue_entered', jsonb_build_object(
    'age_band', v_eligibility.age_band,
    'communication_mode', p_communication_mode,
    'session_length_minutes', greatest(5, least(coalesce(p_session_length_minutes, 25), 60))
  ));
  return v_queue_id;
end;
$$;

create or replace function public.find_body_double_match(p_queue_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_my_entry public.body_double_queue%rowtype;
  v_match_entry public.body_double_queue%rowtype;
  v_session_id uuid;
begin
  update public.body_double_queue set status = 'timeout', updated_at = now()
  where status = 'waiting' and expires_at <= now();

  select * into v_my_entry from public.body_double_queue
  where id = p_queue_id and user_id = auth.uid() and status = 'waiting'
    and expires_at > now() and random_matching_enabled = true
  for update skip locked;
  if not found then return null; end if;

  if v_my_entry.communication_mode not in ('quiet', 'presetSignals', 'textOnly') then return null; end if;
  if v_my_entry.age_band <> 'adult' and (v_my_entry.guardian_approved is not true or v_my_entry.communication_mode not in ('quiet', 'presetSignals')) then return null; end if;
  if exists (
    select 1 from public.body_double_user_restrictions r
    where r.user_id = v_my_entry.user_id and r.status = 'active'
      and r.restriction_type in ('random_suspended', 'body_double_suspended')
      and r.starts_at <= now() and (r.expires_at is null or r.expires_at > now())
  ) then return null; end if;

  select q.* into v_match_entry
  from public.body_double_queue q
  join public.users_profile p on p.id = q.user_id
  where q.status = 'waiting'
    and q.id <> p_queue_id
    and q.user_id <> v_my_entry.user_id
    and q.session_type = v_my_entry.session_type
    and q.age_band = v_my_entry.age_band
    and q.communication_mode = v_my_entry.communication_mode
    and q.session_length_minutes = v_my_entry.session_length_minutes
    and q.privacy_level = v_my_entry.privacy_level
    and q.expires_at > now()
    and q.random_matching_enabled = true
    and q.communication_mode in ('quiet', 'presetSignals', 'textOnly')
    and (q.age_band = 'adult' or (q.guardian_approved = true and q.communication_mode in ('quiet', 'presetSignals')))
    and not exists (select 1 from public.user_blocks b where (b.blocker_id = v_my_entry.user_id and b.blocked_id = q.user_id) or (b.blocker_id = q.user_id and b.blocked_id = v_my_entry.user_id))
    and not exists (
      select 1 from public.body_double_user_restrictions r
      where r.user_id = q.user_id and r.status = 'active'
        and r.restriction_type in ('random_suspended', 'body_double_suspended')
        and r.starts_at <= now() and (r.expires_at is null or r.expires_at > now())
    )
  order by (case when q.language = v_my_entry.language then 0 else 1 end), p.reliability_score desc, q.created_at asc
  limit 1 for update skip locked;

  if found then
    insert into public.body_double_sessions (user_id, mode, status, session_type, session_length_minutes, communication_mode, privacy_level, started_at)
    values (v_my_entry.user_id, 'random', 'active', v_my_entry.session_type, v_my_entry.session_length_minutes, v_my_entry.communication_mode, case when v_my_entry.privacy_level = 'private' then 'private' else 'titleOnly' end, now())
    returning id into v_session_id;

    insert into public.body_double_participants (session_id, user_id, role, status, age_band_snapshot, anonymous_label, joined_at)
    values
      (v_session_id, v_my_entry.user_id, 'random', 'active', v_my_entry.age_band, 'Body double 1', now()),
      (v_session_id, v_match_entry.user_id, 'random', 'active', v_match_entry.age_band, 'Body double 2', now());

    update public.body_double_queue set status = 'matched', matched_session_id = v_session_id, updated_at = now() where id = p_queue_id;
    update public.body_double_queue set status = 'matched', matched_session_id = v_session_id, updated_at = now() where id = v_match_entry.id;

    insert into public.body_double_audit_events(actor_id, session_id, queue_id, event_type, metadata)
    values
      (v_my_entry.user_id, v_session_id, v_my_entry.id, 'random_match_created', jsonb_build_object('age_band', v_my_entry.age_band, 'communication_mode', v_my_entry.communication_mode)),
      (v_match_entry.user_id, v_session_id, v_match_entry.id, 'random_match_created', jsonb_build_object('age_band', v_match_entry.age_band, 'communication_mode', v_match_entry.communication_mode));
    return v_session_id;
  end if;

  return null;
end;
$$;