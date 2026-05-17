-- Phase 3D: Group Random Body Doubling
-- Phase 3E: Optional Voice Random Body Doubling
-- Phase 3F: Trust / Matching Quality

-- 1. Profile and Session Updates
alter table public.users_profile
  add column if not exists reliability_score numeric not null default 1.0;

create index if not exists users_profile_reliability_idx on public.users_profile(reliability_score desc);

alter table public.body_double_sessions
  add column if not exists voice_enabled boolean not null default false;

alter table public.body_double_presence
  add column if not exists steps_completed integer not null default 0;

alter table public.body_double_participants
  add column if not exists steps_completed_snapshot integer not null default 0;

-- 2. Reliability Calculation (Phase 3F)
create or replace function public.calculate_user_reliability(p_user_id uuid)
returns numeric
language plpgsql
security definer
as $$
declare
  v_total integer;
  v_completed integer;
  v_penalties integer;
begin
  select count(*), count(*) filter (where status = 'completed')
  into v_total, v_completed
  from public.body_double_sessions
  where user_id = p_user_id and mode in ('friend', 'random');

  select count(*) into v_penalties
  from public.body_double_audit_events
  where actor_id = p_user_id and event_type = 'reliability_penalty';

  if v_total = 0 then return 1.0; end if;
  return greatest(0, (v_completed::numeric / v_total::numeric) - (v_penalties::numeric * 0.1));
end;
$$;

create or replace function public.on_body_double_session_update_reliability()
returns trigger
language plpgsql
security definer
as $$
begin
  if (TG_OP = 'UPDATE' and (old.status != new.status)) or (TG_OP = 'INSERT') then
    update public.users_profile
    set reliability_score = public.calculate_user_reliability(new.user_id)
    where id = new.user_id;
  end if;
  return new;
end;
$$;

drop trigger if exists body_double_reliability_trigger on public.body_double_sessions;
create trigger body_double_reliability_trigger
  after insert or update on public.body_double_sessions
  for each row execute function public.on_body_double_session_update_reliability();

-- 3. Moderation & Trust Enhancements (Phase 3F)
create or replace function public.review_body_double_report(
  p_report_id uuid,
  p_status text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor_id uuid := auth.uid();
  v_reported_id uuid;
begin
  if v_actor_id is null then raise exception 'Not authenticated'; end if;
  if p_status not in ('pending', 'reviewed', 'actioned', 'dismissed') then raise exception 'Invalid report status'; end if;
  if not public.is_body_double_moderator(v_actor_id) then raise exception 'Only body double moderators can review reports'; end if;

  select reported_id into v_reported_id from public.user_reports where id = p_report_id;

  update public.user_reports set status = p_status where id = p_report_id;

  if p_status = 'actioned' and v_reported_id is not null then
    insert into public.body_double_audit_events(actor_id, event_type, metadata)
    values (v_reported_id, 'reliability_penalty', jsonb_build_object('report_id', p_report_id, 'reason', 'Confirmed safety report'));
    
    update public.users_profile
    set reliability_score = public.calculate_user_reliability(v_reported_id)
    where id = v_reported_id;
  end if;

  insert into public.body_double_audit_events(actor_id, event_type, metadata)
  values (v_actor_id, 'report_reviewed', jsonb_build_object('report_id', p_report_id, 'status', p_status));
end;
$$;

create or replace function public.restrict_body_double_user(
  p_user_id uuid,
  p_restriction_type text,
  p_reason text,
  p_expires_at timestamptz default null,
  p_report_id uuid default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor_id uuid := auth.uid();
  v_restriction_id uuid;
begin
  if v_actor_id is null then raise exception 'Not authenticated'; end if;
  if not public.is_body_double_moderator(v_actor_id) then raise exception 'Only body double moderators can restrict users'; end if;

  insert into public.body_double_user_restrictions (user_id, restricted_by, restriction_type, reason, expires_at)
  values (p_user_id, v_actor_id, p_restriction_type, p_reason, p_expires_at)
  returning id into v_restriction_id;

  insert into public.body_double_audit_events(actor_id, event_type, metadata)
  values (p_user_id, 'reliability_penalty', jsonb_build_object('restriction_id', v_restriction_id, 'reason', 'Moderator restriction'));

  update public.users_profile
  set reliability_score = public.calculate_user_reliability(p_user_id)
  where id = p_user_id;

  insert into public.body_double_audit_events(actor_id, event_type, metadata)
  values (v_actor_id, 'user_restricted', jsonb_build_object('target_user_id', p_user_id, 'restriction_id', v_restriction_id));

  return v_restriction_id;
end;
$$;

-- 4. Settings Policy Update
drop policy if exists "Adults can update own random safety settings." on public.body_double_random_safety_settings;
create policy "Adults can update own random safety settings."
  on public.body_double_random_safety_settings for all
  using (
    auth.uid() = user_id
    and exists (
      select 1 from public.users_profile p
      where p.id = auth.uid()
        and p.age_band = 'adult'
    )
  )
  with check (
    auth.uid() = user_id
    and exists (
      select 1 from public.users_profile p
      where p.id = auth.uid()
        and p.age_band = 'adult'
    )
    and guardian_random_approved = false
  );

-- 5. Constraints for Voice (Phase 3E)
alter table public.body_double_queue drop constraint if exists body_double_queue_communication_mode_check;
alter table public.body_double_queue add constraint body_double_queue_communication_mode_check
  check (communication_mode in ('quiet', 'presetSignals', 'textOnly', 'voice'));

-- 6. Eligibility Function Update
drop function if exists public.get_random_body_double_eligibility(uuid);
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
    coalesce(s.voice_allowed, false) as voice_allowed,
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

-- 7. Queue Entry Function Update
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
  update public.body_double_user_restrictions
  set status = 'expired', updated_at = now()
  where status = 'active'
    and expires_at is not null
    and expires_at <= now();

  if v_user_id is null then raise exception 'Not authenticated'; end if;

  select * into v_eligibility from public.get_random_body_double_eligibility(v_user_id) limit 1;

  if not found or v_eligibility.can_enter_random_queue is not true then
    raise exception 'Random body double is not enabled for this user';
  end if;

  if p_communication_mode not in ('quiet', 'presetSignals', 'textOnly', 'voice') then
    raise exception 'Random body double supports quiet, presetSignals, textOnly, or adult-only voice';
  end if;

  if p_communication_mode = 'voice' and (v_eligibility.age_band <> 'adult' or v_eligibility.voice_allowed is not true) then
    raise exception 'Random voice is adult-only and must be explicitly enabled';
  end if;

  if p_communication_mode = 'textOnly' and (v_eligibility.age_band <> 'adult' or v_eligibility.text_allowed is not true) then
    raise exception 'Random text is adult-only and must be explicitly enabled';
  end if;

  v_safe_privacy := case when p_privacy_level = 'private' then 'private' else 'titleOnly' end;

  update public.body_double_queue set status = 'cancelled', updated_at = now() where user_id = v_user_id and status = 'waiting';

  insert into public.body_double_queue (
    user_id, session_type, task_category, session_length_minutes, communication_mode, privacy_level, status,
    age_band, guardian_approved, random_matching_enabled, language, timezone, expires_at
  )
  values (
    v_user_id, p_session_type, coalesce(nullif(trim(p_task_category), ''), 'general'), greatest(5, least(coalesce(p_session_length_minutes, 25), 60)),
    p_communication_mode, v_safe_privacy, 'waiting', v_eligibility.age_band, v_eligibility.guardian_approved, true,
    coalesce(nullif(trim(p_language), ''), 'en'), p_timezone, now() + interval '10 minutes'
  )
  returning id into v_queue_id;

  insert into public.body_double_audit_events(actor_id, queue_id, event_type, metadata)
  values (v_user_id, v_queue_id, 'random_queue_entered', jsonb_build_object('age_band', v_eligibility.age_band, 'communication_mode', p_communication_mode));

  return v_queue_id;
end;
$$;

-- 8. Adult Settings RPC Update
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

  if v_age_band <> 'adult' then raise exception 'Only adult users can manage their own random body double settings'; end if;

  if p_preset_signals_allowed is not true and p_quiet_mode_allowed is not true then
    raise exception 'At least one safe random communication mode must remain enabled';
  end if;

  insert into public.body_double_random_safety_settings (
    user_id, random_matching_enabled, guardian_random_approved, preset_signals_allowed, quiet_mode_allowed, text_allowed, voice_allowed, updated_at
  )
  values (v_user_id, p_random_matching_enabled, false, p_preset_signals_allowed, p_quiet_mode_allowed, p_text_allowed, p_voice_allowed, now())
  on conflict (user_id) do update set
    random_matching_enabled = excluded.random_matching_enabled,
    guardian_random_approved = false, guardian_approved_by = null, guardian_approved_at = null,
    preset_signals_allowed = excluded.preset_signals_allowed,
    quiet_mode_allowed = excluded.quiet_mode_allowed,
    text_allowed = excluded.text_allowed,
    voice_allowed = excluded.voice_allowed,
    updated_at = now();

  insert into public.body_double_audit_events(actor_id, event_type, metadata)
  values (v_user_id, 'random_safety_settings_updated', jsonb_build_object('random_matching_enabled', p_random_matching_enabled, 'preset_signals_allowed', p_preset_signals_allowed, 'quiet_mode_allowed', p_quiet_mode_allowed, 'text_allowed', p_text_allowed, 'voice_allowed', p_voice_allowed));
end;
$$;

-- 9. Advanced Matching RPC (Group Support & Trust - Phase 3D/F)
create or replace function public.find_body_double_match(p_queue_id uuid)
returns uuid
language plpgsql
security definer
as $$
declare
  v_my_entry public.body_double_queue;
  v_match_session_id uuid;
  v_match_queue_entry public.body_double_queue;
begin
  update public.body_double_queue set status = 'timeout', updated_at = now() where status = 'waiting' and expires_at <= now();

  select * into v_my_entry from public.body_double_queue where id = p_queue_id and user_id = auth.uid() and status = 'waiting' and expires_at > now();
  if not found then return null; end if;

  -- Join existing session (Phase 3D - Groups)
  select s.id into v_match_session_id
  from public.body_double_sessions s
  join public.users_profile host on host.id = s.user_id
  where s.mode = 'random'
    and s.status = 'active'
    and s.session_type = v_my_entry.session_type
    and s.communication_mode = v_my_entry.communication_mode
    and s.session_length_minutes = v_my_entry.session_length_minutes
    and not exists (
      select 1 from public.body_double_participants p
      where p.session_id = s.id and (p.age_band_snapshot != v_my_entry.age_band or p.status = 'removed')
    )
    and (select count(*) from public.body_double_participants p where p.session_id = s.id and p.status in ('joined', 'active', 'accepted')) < 4
    and not exists (
      select 1 from public.body_double_participants p
      join public.user_blocks b on (b.blocker_id = v_my_entry.user_id and b.blocked_id = p.user_id) or (b.blocker_id = p.user_id and b.blocked_id = v_my_entry.user_id)
      where p.session_id = s.id
    )
  order by 
    (case when v_my_entry.language = (select q.language from public.body_double_queue q where q.user_id = s.user_id order by created_at desc limit 1) then 0 else 1 end) asc,
    host.reliability_score desc
  limit 1 for update skip locked;

  if v_match_session_id is not null then
    insert into public.body_double_participants (session_id, user_id, role, status, age_band_snapshot, anonymous_label, joined_at)
    values (v_match_session_id, v_my_entry.user_id, 'random', 'active', v_my_entry.age_band, 'Body double ' || (select count(*) + 1 from public.body_double_participants where session_id = v_match_session_id), now());
    update public.body_double_queue set status = 'matched', matched_session_id = v_match_session_id where id = p_queue_id;
    insert into public.body_double_audit_events(actor_id, session_id, queue_id, event_type, metadata)
    values (v_my_entry.user_id, v_match_session_id, v_my_entry.id, 'random_match_joined_group', jsonb_build_object('age_band', v_my_entry.age_band));
    return v_match_session_id;
  end if;

  -- Create new session (Phase 3F - Trust/Quality Matching)
  select q.id into v_match_queue_entry
  from public.body_double_queue q
  join public.users_profile p on p.id = q.user_id
  where q.status = 'waiting' and q.id != p_queue_id and q.session_type = v_my_entry.session_type and q.age_band = v_my_entry.age_band and q.communication_mode = v_my_entry.communication_mode and q.session_length_minutes = v_my_entry.session_length_minutes and q.expires_at > now()
    and not exists (select 1 from public.user_blocks b where (b.blocker_id = v_my_entry.user_id and b.blocked_id = q.user_id) or (b.blocker_id = q.user_id and b.blocked_id = v_my_entry.user_id))
  order by 
    (case when q.language = v_my_entry.language then 0 else 1 end) asc,
    p.reliability_score desc,
    q.created_at asc 
  limit 1 for update skip locked;

  if v_match_queue_entry is not null then
    insert into public.body_double_sessions (user_id, mode, status, session_type, session_length_minutes, communication_mode, privacy_level, started_at)
    values (v_my_entry.user_id, 'random', 'active', v_my_entry.session_type, v_my_entry.session_length_minutes, v_my_entry.communication_mode, case when v_my_entry.privacy_level = 'private' then 'private' else 'titleOnly' end, now())
    returning id into v_match_session_id;
    insert into public.body_double_participants (session_id, user_id, role, status, age_band_snapshot, anonymous_label, joined_at)
    values (v_match_session_id, v_my_entry.user_id, 'random', 'active', v_my_entry.age_band, 'Body double 1', now()), (v_match_session_id, (select user_id from public.body_double_queue where id = v_match_queue_entry), 'random', 'active', v_my_entry.age_band, 'Body double 2', now());
    update public.body_double_queue set status = 'matched', matched_session_id = v_match_session_id where id = p_queue_id;
    update public.body_double_queue set status = 'matched', matched_session_id = v_match_session_id where id = v_match_queue_entry;
    insert into public.body_double_audit_events(actor_id, session_id, event_type, metadata)
    values (v_my_entry.user_id, v_match_session_id, 'random_match_created', jsonb_build_object('age_band', v_my_entry.age_band)), ((select user_id from public.body_double_queue where id = v_match_queue_entry), v_match_session_id, 'random_match_created', jsonb_build_object('age_band', v_my_entry.age_band));
    return v_match_session_id;
  end if;
  return null;
end;
$$;
