-- Phase 3G: small, safety-gated group body-double runtime.
-- No public rooms, no profile discovery, no random minors, no random voice.

alter table public.body_double_sessions drop constraint if exists body_double_sessions_mode_check;
alter table public.body_double_sessions add constraint body_double_sessions_mode_check
  check (mode in ('dopei', 'friend', 'random', 'knownGroup', 'randomGroup'));

alter table public.body_double_sessions
  add column if not exists created_by uuid references auth.users(id) on delete set null;
alter table public.body_double_sessions
  add column if not exists max_participants integer not null default 1;
alter table public.body_double_sessions
  add column if not exists current_participant_count integer not null default 1;

alter table public.body_double_sessions drop constraint if exists body_double_sessions_group_size_check;
alter table public.body_double_sessions add constraint body_double_sessions_group_size_check
  check (
    (mode not in ('knownGroup', 'randomGroup') and max_participants >= 1)
    or (mode in ('knownGroup', 'randomGroup') and max_participants between 2 and 3)
  );

alter table public.body_double_sessions drop constraint if exists body_double_sessions_random_group_safe_check;
alter table public.body_double_sessions add constraint body_double_sessions_random_group_safe_check
  check (mode <> 'randomGroup' or (communication_mode in ('quiet', 'presetSignals', 'textOnly') and privacy_level in ('private', 'titleOnly')));

alter table public.body_double_participants drop constraint if exists body_double_participants_status_check;
alter table public.body_double_participants add constraint body_double_participants_status_check
  check (status in ('invited', 'accepted', 'declined', 'active', 'left', 'removed', 'reported'));

alter table public.body_double_queue
  add column if not exists wants_group_session boolean not null default false;
alter table public.body_double_queue
  add column if not exists max_group_size integer not null default 2;

create index if not exists body_double_sessions_group_match_idx
  on public.body_double_sessions(mode, status, session_type, communication_mode, privacy_level, session_length_minutes, created_at)
  where mode in ('knownGroup', 'randomGroup');

create index if not exists body_double_queue_group_waiting_idx
  on public.body_double_queue(status, wants_group_session, age_band, communication_mode, session_length_minutes, created_at)
  where wants_group_session = true;

create or replace function public.body_double_active_participant_count(p_session_id uuid)
returns integer
language sql
stable
security definer
set search_path = public
as $$
  select count(*)::integer
  from public.body_double_participants p
  where p.session_id = p_session_id
    and p.status in ('accepted', 'active');
$$;

create or replace function public.body_double_has_active_restriction(p_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.body_double_user_restrictions r
    where r.user_id = p_user_id
      and r.status = 'active'
      and r.restriction_type in ('random_suspended', 'body_double_suspended')
      and r.starts_at <= now()
      and (r.expires_at is null or r.expires_at > now())
  );
$$;

create or replace function public.enter_group_body_double_queue(
  p_session_type text,
  p_task_category text default 'general',
  p_session_length_minutes integer default 25,
  p_communication_mode text default 'presetSignals',
  p_privacy_level text default 'titleOnly',
  p_max_group_size integer default 3,
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
  v_age_band text;
  v_queue_id uuid;
begin
  if v_user_id is null then raise exception 'Not authenticated'; end if;

  select public.normalize_body_double_age_band(age_band) into v_age_band
  from public.users_profile
  where id = v_user_id;

  if v_age_band is null then
    raise exception 'User profile is required for group body double';
  end if;
  if v_age_band <> 'adult' then
    raise exception 'Random group body double is adult-only';
  end if;
  if public.body_double_has_active_restriction(v_user_id) then
    raise exception 'Restricted users cannot enter group body double queue';
  end if;

  select * into v_eligibility from public.get_random_body_double_eligibility(v_user_id) limit 1;
  if not found or v_eligibility.can_enter_random_queue is not true then
    raise exception 'Random group body double is not enabled for this user';
  end if;
  if p_communication_mode not in ('quiet', 'presetSignals', 'textOnly') then
    raise exception 'Random groups do not support unsafe communication modes';
  end if;
  if p_communication_mode = 'textOnly' and v_eligibility.text_allowed is not true then
    raise exception 'Random group text must be explicitly enabled and moderation-safe';
  end if;

  update public.body_double_queue set status = 'cancelled', updated_at = now()
  where user_id = v_user_id and status = 'waiting';

  insert into public.body_double_queue (
    user_id, session_type, task_category, session_length_minutes, communication_mode,
    privacy_level, status, age_band, guardian_approved, random_matching_enabled,
    language, timezone, expires_at, wants_group_session, max_group_size
  ) values (
    v_user_id, p_session_type, coalesce(nullif(trim(p_task_category), ''), 'general'),
    greatest(5, least(coalesce(p_session_length_minutes, 25), 60)), p_communication_mode,
    case when p_privacy_level = 'private' then 'private' else 'titleOnly' end,
    'waiting', 'adult', false, true,
    coalesce(nullif(trim(p_language), ''), 'en'), p_timezone, now() + interval '10 minutes',
    true, greatest(2, least(coalesce(p_max_group_size, 3), 3))
  ) returning id into v_queue_id;

  insert into public.body_double_audit_events(actor_id, queue_id, event_type, metadata)
  values (v_user_id, v_queue_id, 'random_group_queue_entered', jsonb_build_object('max_group_size', greatest(2, least(coalesce(p_max_group_size, 3), 3))));
  return v_queue_id;
end;
$$;

create or replace function public.find_group_body_double_match(p_queue_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_my public.body_double_queue%rowtype;
  v_session_id uuid;
  v_count integer;
begin
  update public.body_double_queue set status = 'timeout', updated_at = now()
  where status = 'waiting' and expires_at <= now();

  select * into v_my from public.body_double_queue
  where id = p_queue_id and user_id = auth.uid() and status = 'waiting'
    and wants_group_session = true and age_band = 'adult' and expires_at > now()
  for update skip locked;
  if not found then return null; end if;
  if public.body_double_has_active_restriction(v_my.user_id) then return null; end if;

  select s.id into v_session_id
  from public.body_double_sessions s
  where s.mode = 'randomGroup'
    and s.status in ('waiting', 'active')
    and s.session_type = v_my.session_type
    and s.communication_mode = v_my.communication_mode
    and s.session_length_minutes = v_my.session_length_minutes
    and s.privacy_level = v_my.privacy_level
    and s.current_participant_count < s.max_participants
    and not exists (select 1 from public.body_double_participants p where p.session_id = s.id and p.user_id = v_my.user_id)
    and not exists (
      select 1 from public.body_double_participants p
      join public.user_blocks b on (b.blocker_id = v_my.user_id and b.blocked_id = p.user_id) or (b.blocker_id = p.user_id and b.blocked_id = v_my.user_id)
      where p.session_id = s.id and p.status in ('accepted', 'active')
    )
  order by s.created_at asc
  limit 1
  for update skip locked;

  if v_session_id is null then
    insert into public.body_double_sessions (
      user_id, created_by, mode, status, session_type, session_length_minutes,
      communication_mode, privacy_level, max_participants, current_participant_count, started_at
    ) values (
      v_my.user_id, v_my.user_id, 'randomGroup', 'waiting', v_my.session_type,
      v_my.session_length_minutes, v_my.communication_mode, v_my.privacy_level,
      greatest(2, least(v_my.max_group_size, 3)), 1, now()
    ) returning id into v_session_id;

    insert into public.body_double_participants(session_id, user_id, role, status, age_band_snapshot, anonymous_label, joined_at)
    values (v_session_id, v_my.user_id, 'host', 'active', 'adult', 'Body double 1', now());
  else
    select public.body_double_active_participant_count(v_session_id) into v_count;
    insert into public.body_double_participants(session_id, user_id, role, status, age_band_snapshot, anonymous_label, joined_at)
    values (v_session_id, v_my.user_id, 'participant', 'active', 'adult', 'Body double ' || (v_count + 1), now());
  end if;

  update public.body_double_sessions
  set current_participant_count = public.body_double_active_participant_count(v_session_id),
      status = case when public.body_double_active_participant_count(v_session_id) >= 2 then 'active' else 'waiting' end,
      updated_at = now()
  where id = v_session_id;

  update public.body_double_queue set status = 'matched', matched_session_id = v_session_id, updated_at = now()
  where id = p_queue_id;

  insert into public.body_double_audit_events(actor_id, session_id, queue_id, event_type, metadata)
  values (v_my.user_id, v_session_id, v_my.id, 'random_group_match_joined', jsonb_build_object('communication_mode', v_my.communication_mode));
  return v_session_id;
end;
$$;

create or replace function public.leave_group_body_double_session(p_session_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_count integer;
begin
  if v_user_id is null then raise exception 'Not authenticated'; end if;
  update public.body_double_participants
  set status = 'left', left_at = coalesce(left_at, now()), updated_at = now()
  where session_id = p_session_id and user_id = v_user_id and status in ('invited', 'accepted', 'active');
  if not found then raise exception 'Only participants can leave a group session'; end if;

  select public.body_double_active_participant_count(p_session_id) into v_count;
  update public.body_double_sessions
  set current_participant_count = v_count,
      status = case when v_count < 2 then 'cancelled' else status end,
      ended_at = case when v_count < 2 then coalesce(ended_at, now()) else ended_at end,
      updated_at = now()
  where id = p_session_id and mode in ('knownGroup', 'randomGroup');

  insert into public.body_double_audit_events(actor_id, session_id, event_type, metadata)
  values (v_user_id, p_session_id, 'group_participant_left', jsonb_build_object('remaining_participants', v_count));
end;
$$;

create or replace function public.create_known_group_body_double_invite(
  p_session_id uuid,
  p_receiver_id uuid
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_invite_id uuid;
begin
  if v_user_id is null then raise exception 'Not authenticated'; end if;
  if p_receiver_id = v_user_id then raise exception 'Cannot invite yourself'; end if;
  if not exists (select 1 from public.body_double_sessions s where s.id = p_session_id and s.mode = 'knownGroup' and s.user_id = v_user_id and s.max_participants <= 3) then
    raise exception 'Only the host can invite trusted people to this known group';
  end if;
  if public.body_double_active_participant_count(p_session_id) >= 3 then
    raise exception 'Group is full';
  end if;
  if not exists (
    select 1 from public.caregiver_links l
    where l.status = 'active'
      and ((l.primary_user_id = v_user_id and l.caregiver_user_id = p_receiver_id) or (l.caregiver_user_id = v_user_id and l.primary_user_id = p_receiver_id))
  ) then
    raise exception 'Known group invites require accepted trusted relationships';
  end if;

  insert into public.body_double_invites(session_id, sender_id, receiver_id, status, expires_at, created_at)
  values (p_session_id, v_user_id, p_receiver_id, 'pending', now() + interval '60 minutes', now())
  returning id into v_invite_id;
  insert into public.body_double_participants(session_id, user_id, role, status)
  values (p_session_id, p_receiver_id, 'participant', 'invited')
  on conflict (session_id, user_id) do nothing;
  return v_invite_id;
end;
$$;