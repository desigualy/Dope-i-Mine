-- Phase 3 Random Body Double Infrastructure.
-- Safety-critical boundary: this migration supports Phase 3A queueing,
-- Phase 3B anonymous preset-signal co-presence, and Phase 3C limited
-- adult-only text via moderated RPC only. It intentionally does not enable
-- profile browsing, direct messages, video, voice, or unrestricted random chat.

create table if not exists public.user_blocks (
  id uuid primary key default gen_random_uuid(),
  blocker_id uuid not null references auth.users(id) on delete cascade,
  blocked_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(blocker_id, blocked_id)
);
alter table public.user_blocks enable row level security;
drop policy if exists "Users can view their own blocks." on public.user_blocks;
create policy "Users can view their own blocks." on public.user_blocks for select using (auth.uid() = blocker_id);
drop policy if exists "Users can block others." on public.user_blocks;
create policy "Users can block others." on public.user_blocks for insert with check (auth.uid() = blocker_id);
drop policy if exists "Users can unblock others." on public.user_blocks;
create policy "Users can unblock others." on public.user_blocks for delete using (auth.uid() = blocker_id);

create table if not exists public.user_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid references auth.users(id) on delete set null,
  reported_id uuid not null references auth.users(id) on delete cascade,
  session_id uuid references public.body_double_sessions(id) on delete set null,
  reason text not null,
  details text,
  status text not null default 'pending' check (status in ('pending', 'reviewed', 'actioned', 'dismissed')),
  created_at timestamptz not null default now()
);
alter table public.user_reports enable row level security;
drop policy if exists "Users can submit reports." on public.user_reports;
create policy "Users can submit reports." on public.user_reports for insert with check (auth.uid() = reporter_id);
drop policy if exists "Users can view their own submitted reports." on public.user_reports;
create policy "Users can view their own submitted reports." on public.user_reports for select using (auth.uid() = reporter_id);

create table if not exists public.body_double_user_restrictions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  restricted_by uuid references auth.users(id) on delete set null,
  restriction_type text not null check (
    restriction_type in ('random_suspended', 'body_double_suspended')
  ),
  reason text not null,
  status text not null default 'active' check (status in ('active', 'expired', 'revoked')),
  starts_at timestamptz not null default now(),
  expires_at timestamptz null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.body_double_user_restrictions enable row level security;

drop policy if exists "Users can view own body double restrictions"
  on public.body_double_user_restrictions;
create policy "Users can view own body double restrictions"
  on public.body_double_user_restrictions for select
  using (auth.uid() = user_id);

create table if not exists public.body_double_moderators (
  user_id uuid primary key references public.users_profile(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.body_double_moderators enable row level security;

create or replace function public.is_body_double_moderator(
  p_user_id uuid default auth.uid()
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.body_double_moderators m
    where m.user_id = p_user_id
  );
$$;

drop policy if exists "Moderators can view moderator list"
  on public.body_double_moderators;
create policy "Moderators can view moderator list"
  on public.body_double_moderators for select
  using (public.is_body_double_moderator(auth.uid()));

create table if not exists public.body_double_audit_events (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references auth.users(id) on delete set null,
  session_id uuid references public.body_double_sessions(id) on delete set null,
  queue_id uuid null,
  event_type text not null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
alter table public.body_double_audit_events enable row level security;

drop policy if exists "Users can view their own body double audit events."
  on public.body_double_audit_events;
create policy "Users can view their own body double audit events."
  on public.body_double_audit_events for select
  using (
    auth.uid() = actor_id
    or public.is_body_double_moderator(auth.uid())
  );

drop policy if exists "Moderators can view body double reports"
  on public.user_reports;
create policy "Moderators can view body double reports"
  on public.user_reports for select
  using (public.is_body_double_moderator(auth.uid()));

drop policy if exists "Moderators can update body double reports"
  on public.user_reports;
create policy "Moderators can update body double reports"
  on public.user_reports for update
  using (public.is_body_double_moderator(auth.uid()))
  with check (public.is_body_double_moderator(auth.uid()));

drop policy if exists "Moderators can view body double restrictions"
  on public.body_double_user_restrictions;
create policy "Moderators can view body double restrictions"
  on public.body_double_user_restrictions for select
  using (public.is_body_double_moderator(auth.uid()));

drop policy if exists "Moderators can insert body double restrictions"
  on public.body_double_user_restrictions;
create policy "Moderators can insert body double restrictions"
  on public.body_double_user_restrictions for insert
  with check (public.is_body_double_moderator(auth.uid()));

drop policy if exists "Moderators can update body double restrictions"
  on public.body_double_user_restrictions;
create policy "Moderators can update body double restrictions"
  on public.body_double_user_restrictions for update
  using (public.is_body_double_moderator(auth.uid()))
  with check (public.is_body_double_moderator(auth.uid()));

create table if not exists public.caregiver_links (
  id uuid primary key default gen_random_uuid(),
  primary_user_id uuid not null references public.users_profile(id) on delete cascade,
  caregiver_user_id uuid not null references public.users_profile(id) on delete cascade,
  permission_level text not null default 'support',
  status text not null default 'active' check (status in ('pending', 'active', 'revoked')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(primary_user_id, caregiver_user_id)
);

alter table public.caregiver_links enable row level security;

drop policy if exists "caregiver_links_visible_to_linked_users"
  on public.caregiver_links;
create policy "caregiver_links_visible_to_linked_users"
  on public.caregiver_links for select
  using (auth.uid() = primary_user_id or auth.uid() = caregiver_user_id);

drop policy if exists "caregiver_links_primary_user_insert"
  on public.caregiver_links;
create policy "caregiver_links_primary_user_insert"
  on public.caregiver_links for insert
  with check (auth.uid() = primary_user_id);

drop policy if exists "caregiver_links_linked_users_update"
  on public.caregiver_links;
create policy "caregiver_links_linked_users_update"
  on public.caregiver_links for update
  using (auth.uid() = primary_user_id or auth.uid() = caregiver_user_id)
  with check (auth.uid() = primary_user_id or auth.uid() = caregiver_user_id);

create table if not exists public.body_double_random_safety_settings (
  user_id uuid primary key references public.users_profile(id) on delete cascade,
  random_matching_enabled boolean not null default false,
  guardian_random_approved boolean not null default false,
  guardian_approved_by uuid references auth.users(id) on delete set null,
  guardian_approved_at timestamptz null,
  preset_signals_allowed boolean not null default true,
  quiet_mode_allowed boolean not null default true,
  text_allowed boolean not null default false,
  voice_allowed boolean not null default false,
  updated_at timestamptz not null default now(),
  check (preset_signals_allowed = true or quiet_mode_allowed = true)
);

alter table public.body_double_random_safety_settings enable row level security;

drop policy if exists "Users can view own random safety settings."
  on public.body_double_random_safety_settings;
create policy "Users can view own random safety settings."
  on public.body_double_random_safety_settings for select
  using (auth.uid() = user_id);

drop policy if exists "Adults can update own random safety settings."
  on public.body_double_random_safety_settings;
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
    and voice_allowed = false
  );

create table if not exists public.body_double_queue (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  session_type text not null,
  task_category text not null default 'general',
  session_length_minutes integer not null default 25,
  communication_mode text not null default 'presetSignals' check (
    communication_mode in ('quiet', 'presetSignals', 'textOnly')
  ),
  privacy_level text not null default 'titleOnly',
  matched_session_id uuid references public.body_double_sessions(id) on delete set null,
  status text not null default 'waiting' check (status in ('waiting', 'matched', 'cancelled', 'timeout')),
  age_band text not null check (age_band in ('child', 'preTeen', 'teen', 'adult')),
  guardian_approved boolean not null default false,
  random_matching_enabled boolean not null default false,
  language text not null default 'en',
  timezone text null,
  expires_at timestamptz not null default (now() + interval '10 minutes'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.body_double_queue
  add column if not exists task_category text not null default 'general';
alter table public.body_double_queue
  add column if not exists session_length_minutes integer not null default 25;
alter table public.body_double_queue
  add column if not exists communication_mode text not null default 'presetSignals';
alter table public.body_double_queue
  add column if not exists age_band text;
alter table public.body_double_queue
  add column if not exists guardian_approved boolean not null default false;
alter table public.body_double_queue
  add column if not exists random_matching_enabled boolean not null default false;
alter table public.body_double_queue
  add column if not exists language text not null default 'en';
alter table public.body_double_queue
  add column if not exists timezone text null;
alter table public.body_double_queue
  add column if not exists expires_at timestamptz not null default (now() + interval '10 minutes');

do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'body_double_queue'
      and column_name = 'age_group'
  ) then
    update public.body_double_queue
    set age_band = coalesce(
      age_band,
      case
        when age_group = 'teen' then 'teen'
        when age_group = 'child' then 'child'
        else 'adult'
      end
    )
    where age_band is null;
  else
    update public.body_double_queue
    set age_band = coalesce(age_band, 'adult')
    where age_band is null;
  end if;
end $$;

alter table public.body_double_queue
  alter column age_band set not null;

alter table public.body_double_queue drop constraint if exists body_double_queue_age_group_check;
alter table public.body_double_queue drop constraint if exists body_double_queue_age_band_check;
alter table public.body_double_queue add constraint body_double_queue_age_band_check
  check (age_band in ('child', 'preTeen', 'teen', 'adult'));
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

alter table public.body_double_queue enable row level security;
drop policy if exists "Users can manage their queue entries."
  on public.body_double_queue;
drop policy if exists "Users can view own queue entries."
  on public.body_double_queue;
create policy "Users can view own queue entries."
  on public.body_double_queue for select
  using (auth.uid() = user_id);
drop policy if exists "Users can only cancel own queue entries."
  on public.body_double_queue;
create policy "Users can only cancel own queue entries."
  on public.body_double_queue for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id and status = 'cancelled');

create index if not exists body_double_queue_waiting_match_idx
  on public.body_double_queue(status, age_band, communication_mode, session_type, created_at)
  where status = 'waiting';

create or replace function public.is_body_double_participant(
  p_session_id uuid,
  p_user_id uuid default auth.uid()
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.body_double_participants p
    where p.session_id = p_session_id
      and p.user_id = p_user_id
  );
$$;

drop policy if exists "body_double_participants_visible_to_participant"
  on public.body_double_participants;
create policy "body_double_participants_visible_to_participant"
  on public.body_double_participants for select
  using (
    auth.uid() = user_id
    or public.is_body_double_participant(session_id, auth.uid())
  );

drop policy if exists "body_double_presence_visible_to_session_participants"
  on public.body_double_presence;
create policy "body_double_presence_visible_to_session_participants"
  on public.body_double_presence for select
  using (public.is_body_double_participant(session_id, auth.uid()));

drop policy if exists "body_double_messages_visible_to_session_participants"
  on public.body_double_messages;
create policy "body_double_messages_visible_to_session_participants"
  on public.body_double_messages for select
  using (public.is_body_double_participant(session_id, auth.uid()));

alter table public.body_double_sessions drop constraint if exists body_double_sessions_random_mode_safe_check;
alter table public.body_double_sessions add constraint body_double_sessions_random_mode_safe_check
  check (mode <> 'random' or communication_mode in ('quiet', 'presetSignals', 'textOnly'));

drop policy if exists "body_double_sessions_visible_to_participants"
  on public.body_double_sessions;
create policy "body_double_sessions_visible_to_participants"
  on public.body_double_sessions for select
  using (
    auth.uid() = user_id
    or public.is_body_double_participant(id, auth.uid())
  );

drop policy if exists "body_double_messages_sender_insert"
  on public.body_double_messages;
drop policy if exists "body_double_random_preset_messages_only"
  on public.body_double_messages;
create policy "body_double_random_preset_messages_only"
  on public.body_double_messages for insert
  with check (
    auth.uid() = sender_id
    and exists (
      select 1 from public.body_double_sessions s
      where s.id = body_double_messages.session_id
        and (
          s.mode <> 'random'
          or (
            body_double_messages.message_type = 'preset'
            and body_double_messages.body in (
              'I’m starting',
              'Still here',
              'Taking a short break',
              'Back now',
              'Step done',
              'Wrapping up',
              'Thanks'
            )
          )
        )
    )
  );

create table if not exists public.body_double_message_moderation_events (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.body_double_sessions(id) on delete cascade,
  sender_id uuid references auth.users(id) on delete set null,
  message_id uuid references public.body_double_messages(id) on delete set null,
  report_id uuid references public.user_reports(id) on delete set null,
  action text not null check (action in ('allowed', 'blocked', 'reported')),
  reason text not null,
  body_preview text,
  created_at timestamptz not null default now()
);

alter table public.body_double_message_moderation_events
  add column if not exists report_id uuid references public.user_reports(id) on delete set null;

create index if not exists body_double_message_moderation_report_idx
  on public.body_double_message_moderation_events(report_id)
  where report_id is not null;

alter table public.body_double_message_moderation_events enable row level security;

drop policy if exists "body_double_message_moderation_visible_to_moderators"
  on public.body_double_message_moderation_events;
create policy "body_double_message_moderation_visible_to_moderators"
  on public.body_double_message_moderation_events for select
  using (public.is_body_double_moderator(auth.uid()));

create or replace function public.normalize_body_double_age_band(p_age_band text)
returns text
language sql
immutable
as $$
  select case
    when p_age_band in ('child', 'preTeen', 'teen', 'adult') then p_age_band
    when p_age_band = 'preteen' then 'preTeen'
    else 'adult'
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

  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  select * into v_eligibility
  from public.get_random_body_double_eligibility(v_user_id)
  limit 1;

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

  if p_communication_mode = 'textOnly' and (
    v_eligibility.age_band <> 'adult' or v_eligibility.text_allowed is not true
  ) then
    raise exception 'Random text is adult-only and must be explicitly enabled';
  end if;

  v_safe_privacy := case when p_privacy_level = 'private' then 'private' else 'titleOnly' end;

  update public.body_double_queue
  set status = 'cancelled', updated_at = now()
  where user_id = v_user_id and status = 'waiting';

  insert into public.body_double_queue (
    user_id,
    session_type,
    task_category,
    session_length_minutes,
    communication_mode,
    privacy_level,
    status,
    age_band,
    guardian_approved,
    random_matching_enabled,
    language,
    timezone,
    expires_at
  )
  values (
    v_user_id,
    p_session_type,
    coalesce(nullif(trim(p_task_category), ''), 'general'),
    greatest(5, least(coalesce(p_session_length_minutes, 25), 60)),
    p_communication_mode,
    v_safe_privacy,
    'waiting',
    v_eligibility.age_band,
    v_eligibility.guardian_approved,
    true,
    coalesce(nullif(trim(p_language), ''), 'en'),
    p_timezone,
    now() + interval '10 minutes'
  )
  returning id into v_queue_id;

  insert into public.body_double_audit_events(actor_id, queue_id, event_type, metadata)
  values (
    v_user_id,
    v_queue_id,
    'random_queue_entered',
    jsonb_build_object(
      'age_band', v_eligibility.age_band,
      'communication_mode', p_communication_mode,
      'session_length_minutes', greatest(5, least(coalesce(p_session_length_minutes, 25), 60))
    )
  );

  return v_queue_id;
end;
$$;

create or replace function public.cancel_random_body_double_queue(p_queue_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  update public.body_double_queue
  set status = 'cancelled', updated_at = now()
  where id = p_queue_id
    and user_id = v_user_id
    and status = 'waiting';

  insert into public.body_double_audit_events(actor_id, queue_id, event_type)
  values (v_user_id, p_queue_id, 'random_queue_cancelled');
end;
$$;

create or replace function public.set_adult_random_body_double_settings(
  p_random_matching_enabled boolean,
  p_preset_signals_allowed boolean default true,
  p_quiet_mode_allowed boolean default true,
  p_text_allowed boolean default false
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
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  select public.normalize_body_double_age_band(age_band) into v_age_band
  from public.users_profile
  where id = v_user_id;

  if v_age_band <> 'adult' then
    raise exception 'Only adult users can manage their own random body double settings';
  end if;

  if p_preset_signals_allowed is not true and p_quiet_mode_allowed is not true then
    raise exception 'At least one safe random communication mode must remain enabled';
  end if;

  insert into public.body_double_random_safety_settings (
    user_id,
    random_matching_enabled,
    guardian_random_approved,
    preset_signals_allowed,
    quiet_mode_allowed,
    text_allowed,
    voice_allowed,
    updated_at
  )
  values (
    v_user_id,
    p_random_matching_enabled,
    false,
    p_preset_signals_allowed,
    p_quiet_mode_allowed,
    p_text_allowed,
    false,
    now()
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
  values (
    v_user_id,
    'random_safety_settings_updated',
    jsonb_build_object(
      'random_matching_enabled', p_random_matching_enabled,
      'preset_signals_allowed', p_preset_signals_allowed,
      'quiet_mode_allowed', p_quiet_mode_allowed,
      'text_allowed', p_text_allowed
    )
  );
end;
$$;

create or replace function public.body_double_random_text_block_reason(p_body text)
returns text
language plpgsql
immutable
as $$
declare
  v_body text := lower(coalesce(p_body, ''));
begin
  if length(trim(coalesce(p_body, ''))) = 0 then
    return 'empty';
  end if;
  if length(trim(p_body)) > 160 then
    return 'too_long';
  end if;
  if v_body ~ '([[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}|\+?[0-9][0-9[:space:]().-]{7,}[0-9]|@[a-z0-9_.-]{3,})' then
    return 'contact_info';
  end if;
  if v_body ~ '(https?://|www\.|\.com\y|\.net\y|\.org\y|\.io\y)' then
    return 'link';
  end if;
  if v_body ~ '\y(where do you live|your address|my address|meet me|location|postcode|zip code)\y' then
    return 'location_request';
  end if;
  if v_body ~ '\y(sex|sexual|nude|kill yourself|kys|suicide|self[- ]?harm|fuck|shit|bitch|cunt)\y' then
    return 'unsafe_content';
  end if;
  return null;
end;
$$;

create or replace function public.send_random_body_double_text_message(
  p_session_id uuid,
  p_body text
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_sender_id uuid := auth.uid();
  v_message_id uuid;
  v_reason text;
  v_clean_body text := regexp_replace(trim(coalesce(p_body, '')), '\s+', ' ', 'g');
begin
  if v_sender_id is null then
    raise exception 'Not authenticated';
  end if;

  if not exists (
    select 1
    from public.body_double_sessions s
    join public.body_double_participants p on p.session_id = s.id
    join public.users_profile profile on profile.id = v_sender_id
    left join public.body_double_random_safety_settings settings on settings.user_id = v_sender_id
    where s.id = p_session_id
      and s.mode = 'random'
      and s.communication_mode = 'textOnly'
      and s.status = 'active'
      and p.user_id = v_sender_id
      and p.status in ('accepted', 'active')
      and public.normalize_body_double_age_band(profile.age_band) = 'adult'
      and coalesce(settings.text_allowed, false) = true
  ) then
    raise exception 'Random text requires an active adult-only text session';
  end if;

  if exists (
    select 1 from public.body_double_messages m
    where m.session_id = p_session_id
      and m.sender_id = v_sender_id
      and m.created_at > now() - interval '10 seconds'
  ) then
    insert into public.body_double_message_moderation_events(
      session_id, sender_id, action, reason, body_preview
    ) values (p_session_id, v_sender_id, 'blocked', 'rate_limited', left(v_clean_body, 80));
    raise exception 'Please slow down. Random text is rate limited.';
  end if;

  v_reason := public.body_double_random_text_block_reason(v_clean_body);
  if v_reason is not null then
    insert into public.body_double_message_moderation_events(
      session_id, sender_id, action, reason, body_preview
    ) values (p_session_id, v_sender_id, 'blocked', v_reason, left(v_clean_body, 80));
    raise exception 'Message blocked by random body double safety filter: %', v_reason;
  end if;

  insert into public.body_double_messages(session_id, sender_id, message_type, body)
  values (p_session_id, v_sender_id, 'text', v_clean_body)
  returning id into v_message_id;

  insert into public.body_double_message_moderation_events(
    session_id, sender_id, message_id, action, reason, body_preview
  ) values (p_session_id, v_sender_id, v_message_id, 'allowed', 'passed_filter', left(v_clean_body, 80));

  insert into public.body_double_audit_events(actor_id, session_id, event_type, metadata)
  values (
    v_sender_id,
    p_session_id,
    'random_text_message_sent',
    jsonb_build_object('message_id', v_message_id, 'length', length(v_clean_body))
  );

  return v_message_id;
end;
$$;

create or replace function public.set_minor_random_body_double_guardian_approval(
  p_target_user_id uuid,
  p_approved boolean
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor_id uuid := auth.uid();
  v_target_age_band text;
begin
  if v_actor_id is null then
    raise exception 'Not authenticated';
  end if;

  select public.normalize_body_double_age_band(age_band) into v_target_age_band
  from public.users_profile
  where id = p_target_user_id;

  if v_target_age_band is null then
    raise exception 'Target user profile not found';
  end if;

  if v_target_age_band = 'adult' then
    raise exception 'Guardian approval is only for minor users';
  end if;

  if not exists (
    select 1 from public.caregiver_links l
    where l.primary_user_id = p_target_user_id
      and l.caregiver_user_id = v_actor_id
      and l.status = 'active'
  ) then
    raise exception 'Guardian approval requires an active caregiver relationship';
  end if;

  insert into public.body_double_random_safety_settings (
    user_id,
    random_matching_enabled,
    guardian_random_approved,
    guardian_approved_by,
    guardian_approved_at,
    preset_signals_allowed,
    quiet_mode_allowed,
    text_allowed,
    voice_allowed,
    updated_at
  )
  values (
    p_target_user_id,
    p_approved,
    p_approved,
    case when p_approved then v_actor_id else null end,
    case when p_approved then now() else null end,
    true,
    true,
    false,
    false,
    now()
  )
  on conflict (user_id) do update set
    random_matching_enabled = excluded.random_matching_enabled,
    guardian_random_approved = excluded.guardian_random_approved,
    guardian_approved_by = excluded.guardian_approved_by,
    guardian_approved_at = excluded.guardian_approved_at,
    preset_signals_allowed = true,
    quiet_mode_allowed = true,
    text_allowed = false,
    voice_allowed = false,
    updated_at = now();

  insert into public.body_double_audit_events(actor_id, event_type, metadata)
  values (
    v_actor_id,
    'guardian_random_approval_updated',
    jsonb_build_object('target_user_id', p_target_user_id, 'approved', p_approved)
  );
end;
$$;

create or replace function public.report_random_body_double_session(
  p_session_id uuid,
  p_reported_user_id uuid,
  p_reason text,
  p_details text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_reporter_id uuid := auth.uid();
  v_report_id uuid;
begin
  if v_reporter_id is null then
    raise exception 'Not authenticated';
  end if;

  if not exists (
    select 1 from public.body_double_participants p
    where p.session_id = p_session_id
      and p.user_id = v_reporter_id
  ) then
    raise exception 'Reporter is not a session participant';
  end if;

  if not exists (
    select 1 from public.body_double_participants p
    where p.session_id = p_session_id
      and p.user_id = p_reported_user_id
  ) then
    raise exception 'Reported user is not a session participant';
  end if;

  insert into public.user_reports (
    reporter_id,
    reported_id,
    session_id,
    reason,
    details
  )
  values (
    v_reporter_id,
    p_reported_user_id,
    p_session_id,
    coalesce(nullif(trim(p_reason), ''), 'Safety concern'),
    p_details
  )
  returning id into v_report_id;

  insert into public.user_blocks(blocker_id, blocked_id)
  values (v_reporter_id, p_reported_user_id)
  on conflict do nothing;

  insert into public.body_double_message_moderation_events(
    session_id,
    sender_id,
    report_id,
    action,
    reason,
    body_preview
  )
  values (
    p_session_id,
    p_reported_user_id,
    v_report_id,
    'reported',
    coalesce(nullif(trim(p_reason), ''), 'Safety concern'),
    left(coalesce(p_details, ''), 80)
  );

  update public.body_double_sessions
  set status = 'reported', ended_at = coalesce(ended_at, now()), updated_at = now()
  where id = p_session_id and mode = 'random';

  update public.body_double_participants
  set status = 'left', left_at = coalesce(left_at, now()), updated_at = now()
  where session_id = p_session_id
    and user_id = v_reporter_id;

  insert into public.body_double_audit_events(actor_id, session_id, event_type, metadata)
  values (
    v_reporter_id,
    p_session_id,
    'random_session_reported',
    jsonb_build_object('reported_user_id', p_reported_user_id, 'report_id', v_report_id)
  );

  return v_report_id;
end;
$$;

create or replace function public.cleanup_body_double_random_lifecycle(
  p_inactive_after interval default interval '5 minutes',
  p_presence_timeout interval default interval '2 minutes'
)
returns table(expired_queues integer, stale_presence integer, closed_sessions integer)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_expired integer := 0;
  v_stale_presence integer := 0;
  v_closed integer := 0;
begin
  update public.body_double_user_restrictions
  set status = 'expired', updated_at = now()
  where status = 'active'
    and expires_at is not null
    and expires_at <= now();

  update public.body_double_queue
  set status = 'timeout', updated_at = now()
  where status = 'waiting' and expires_at <= now();
  get diagnostics v_expired = row_count;

  update public.body_double_presence p
  set status = 'timeout', updated_at = now()
  where p.updated_at < now() - p_presence_timeout
    and exists (
      select 1 from public.body_double_sessions s
      where s.id = p.session_id
        and s.mode = 'random'
        and s.status in ('waiting', 'active', 'paused')
    )
    and p.status <> 'timeout';
  get diagnostics v_stale_presence = row_count;

  update public.body_double_sessions s
  set status = 'cancelled',
      ended_at = coalesce(s.ended_at, now()),
      updated_at = now(),
      summary = coalesce(s.summary, 'Random body double session closed after inactivity.')
  where s.mode = 'random'
    and s.status in ('waiting', 'active', 'paused')
    and not exists (
      select 1 from public.body_double_presence p
      where p.session_id = s.id
        and p.updated_at >= now() - p_inactive_after
    )
    and s.created_at < now() - p_inactive_after;
  get diagnostics v_closed = row_count;

  insert into public.body_double_audit_events(event_type, metadata)
  values (
    'random_lifecycle_cleanup',
    jsonb_build_object(
      'expired_queues', v_expired,
      'stale_presence', v_stale_presence,
      'closed_sessions', v_closed
    )
  );

  return query select v_expired, v_stale_presence, v_closed;
end;
$$;

create or replace function public.cleanup_body_double_moderation_retention(
  p_allowed_preview_after interval default interval '30 days',
  p_blocked_preview_after interval default interval '90 days',
  p_reported_preview_after interval default interval '180 days',
  p_audit_actor_after interval default interval '1 year'
)
returns table(
  allowed_previews_scrubbed integer,
  blocked_previews_scrubbed integer,
  reported_previews_scrubbed integer,
  audit_actors_anonymised integer
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor_id uuid := auth.uid();
  v_allowed integer := 0;
  v_blocked integer := 0;
  v_reported integer := 0;
  v_audit integer := 0;
begin
  if v_actor_id is null then
    raise exception 'Not authenticated';
  end if;

  if not public.is_body_double_moderator(v_actor_id) then
    raise exception 'Only body double moderators can run retention cleanup';
  end if;

  -- Policy: allowed random text previews are retained for 30 days by default.
  update public.body_double_message_moderation_events
  set body_preview = null
  where action = 'allowed'
    and body_preview is not null
    and created_at < now() - p_allowed_preview_after;
  get diagnostics v_allowed = row_count;

  -- Policy: blocked random text previews are retained for 90 days by default.
  update public.body_double_message_moderation_events
  set body_preview = null
  where action = 'blocked'
    and body_preview is not null
    and created_at < now() - p_blocked_preview_after;
  get diagnostics v_blocked = row_count;

  -- Policy: reported previews are retained for 180 days by default after review
  -- unless the linked report is still pending or actioned for enforcement.
  update public.body_double_message_moderation_events e
  set body_preview = null
  where e.action = 'reported'
    and e.body_preview is not null
    and e.created_at < now() - p_reported_preview_after
    and (
      e.report_id is null
      or exists (
        select 1 from public.user_reports r
        where r.id = e.report_id
          and r.status in ('reviewed', 'dismissed')
      )
    );
  get diagnostics v_reported = row_count;

  -- Policy: audit events without preview content may retain operational metadata
  -- for one year, then anonymise actor IDs where feasible.
  update public.body_double_audit_events
  set actor_id = null
  where actor_id is not null
    and created_at < now() - p_audit_actor_after;
  get diagnostics v_audit = row_count;

  insert into public.body_double_audit_events(actor_id, event_type, metadata)
  values (
    v_actor_id,
    'body_double_moderation_retention_cleanup',
    jsonb_build_object(
      'allowed_previews_scrubbed', v_allowed,
      'blocked_previews_scrubbed', v_blocked,
      'reported_previews_scrubbed', v_reported,
      'audit_actors_anonymised', v_audit
    )
  );

  return query select v_allowed, v_blocked, v_reported, v_audit;
end;
$$;

create or replace function public.body_double_presence_heartbeat(
  p_session_id uuid,
  p_status text default 'still_here'
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  if p_status not in ('still_here', 'paused', 'break', 'active') then
    raise exception 'Invalid presence status';
  end if;

  if not exists (
    select 1 from public.body_double_participants p
    where p.session_id = p_session_id
      and p.user_id = v_user_id
      and p.status in ('accepted', 'active')
  ) then
    raise exception 'Presence heartbeat requires session participation';
  end if;

  insert into public.body_double_presence(session_id, user_id, status, updated_at)
  values (p_session_id, v_user_id, p_status, now())
  on conflict (session_id, user_id) do update set
    status = excluded.status,
    updated_at = now();
end;
$$;

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
begin
  if v_actor_id is null then
    raise exception 'Not authenticated';
  end if;

  if p_status not in ('pending', 'reviewed', 'actioned', 'dismissed') then
    raise exception 'Invalid report status';
  end if;

  if not public.is_body_double_moderator(v_actor_id) then
    raise exception 'Only body double moderators can review reports';
  end if;

  update public.user_reports
  set status = p_status
  where id = p_report_id;

  insert into public.body_double_audit_events(actor_id, event_type, metadata)
  values (
    v_actor_id,
    'body_double_report_reviewed',
    jsonb_build_object('report_id', p_report_id, 'status', p_status)
  );
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
  if v_actor_id is null then
    raise exception 'Not authenticated';
  end if;

  if not public.is_body_double_moderator(v_actor_id) then
    raise exception 'Only body double moderators can restrict users';
  end if;

  if p_restriction_type not in ('random_suspended', 'body_double_suspended') then
    raise exception 'Invalid body double restriction type';
  end if;

  insert into public.body_double_user_restrictions (
    user_id,
    restricted_by,
    restriction_type,
    reason,
    expires_at
  )
  values (
    p_user_id,
    v_actor_id,
    p_restriction_type,
    coalesce(nullif(trim(p_reason), ''), 'Body double safety restriction'),
    p_expires_at
  )
  returning id into v_restriction_id;

  update public.body_double_queue
  set status = 'cancelled', updated_at = now()
  where user_id = p_user_id
    and status = 'waiting';

  update public.body_double_sessions s
  set status = 'cancelled',
      ended_at = coalesce(s.ended_at, now()),
      updated_at = now(),
      summary = coalesce(s.summary, 'Body double session ended by safety moderation.')
  where s.status in ('waiting', 'active', 'paused')
    and (
      s.user_id = p_user_id
      or exists (
        select 1 from public.body_double_participants p
        where p.session_id = s.id
          and p.user_id = p_user_id
      )
    )
    and (
      p_restriction_type = 'body_double_suspended'
      or s.mode = 'random'
    );

  if p_report_id is not null then
    update public.user_reports
    set status = 'actioned'
    where id = p_report_id;
  end if;

  insert into public.body_double_audit_events(actor_id, event_type, metadata)
  values (
    v_actor_id,
    'body_double_user_restricted',
    jsonb_build_object(
      'target_user_id', p_user_id,
      'restriction_id', v_restriction_id,
      'restriction_type', p_restriction_type,
      'report_id', p_report_id
    )
  );

  return v_restriction_id;
end;
$$;

create or replace function public.revoke_body_double_user_restriction(
  p_restriction_id uuid,
  p_reason text default 'Restriction revoked after review'
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor_id uuid := auth.uid();
begin
  if v_actor_id is null then
    raise exception 'Not authenticated';
  end if;

  if not public.is_body_double_moderator(v_actor_id) then
    raise exception 'Only body double moderators can revoke restrictions';
  end if;

  update public.body_double_user_restrictions
  set status = 'revoked', updated_at = now()
  where id = p_restriction_id;

  insert into public.body_double_audit_events(actor_id, event_type, metadata)
  values (
    v_actor_id,
    'body_double_user_restriction_revoked',
    jsonb_build_object('restriction_id', p_restriction_id, 'reason', p_reason)
  );
end;
$$;

do $$
begin
  create extension if not exists pg_cron with schema extensions;
exception
  when insufficient_privilege or undefined_file then
    insert into public.body_double_audit_events(event_type, metadata)
    values (
      'random_lifecycle_cron_not_installed',
      jsonb_build_object(
        'reason', 'pg_cron extension unavailable; configure an external worker to call cleanup_body_double_random_lifecycle every minute'
      )
    );
end $$;

do $$
begin
  if to_regclass('cron.job') is not null and exists (
    select 1 from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'cron'
      and p.proname = 'schedule'
  ) then
    if not exists (
      select 1 from cron.job
      where jobname = 'body-double-random-lifecycle-cleanup'
    ) then
      perform cron.schedule(
        'body-double-random-lifecycle-cleanup',
        '* * * * *',
        'select * from public.cleanup_body_double_random_lifecycle();'
      );
    end if;
  end if;
exception
  when others then
    insert into public.body_double_audit_events(event_type, metadata)
    values (
      'random_lifecycle_cron_schedule_failed',
      jsonb_build_object(
        'sqlstate', sqlstate,
        'message', sqlerrm,
        'fallback', 'Run select * from public.cleanup_body_double_random_lifecycle(); from an external worker every minute'
      )
    );
end $$;

-- RPC for attempting to find a match (simplified matching logic)
-- In a full prod system, this might be a cron or edge function. 
-- We'll write a simple stored procedure that can be called by a client.
create or replace function public.find_body_double_match(p_queue_id uuid)
returns uuid
language plpgsql
security definer
as $$
declare
  v_my_entry public.body_double_queue;
  v_match_entry public.body_double_queue;
  v_session_id uuid;
begin
  update public.body_double_queue
  set status = 'timeout', updated_at = now()
  where status = 'waiting' and expires_at <= now();

  select * into v_my_entry
  from public.body_double_queue
  where id = p_queue_id
    and user_id = auth.uid()
    and status = 'waiting'
    and expires_at > now()
    and random_matching_enabled = true;
  if not found then
    return null;
  end if;

  if v_my_entry.age_band <> 'adult' and v_my_entry.guardian_approved is not true then
    return null;
  end if;

  if exists (
    select 1 from public.body_double_user_restrictions r
    where r.user_id = v_my_entry.user_id
      and r.status = 'active'
      and r.restriction_type in ('random_suspended', 'body_double_suspended')
      and r.starts_at <= now()
      and (r.expires_at is null or r.expires_at > now())
  ) then
    return null;
  end if;

  -- Safety: exact age-band matching only. This prevents adult/minor matching
  -- and avoids broad child/pre-teen/teen mixing until dedicated moderation and
  -- guardian settings are proven.
  select * into v_match_entry 
  from public.body_double_queue q
  where q.status = 'waiting'
    and q.id != p_queue_id
    and q.session_type = v_my_entry.session_type
    and q.age_band = v_my_entry.age_band
    and q.communication_mode = v_my_entry.communication_mode
    and q.session_length_minutes = v_my_entry.session_length_minutes
    and q.expires_at > now()
    and q.random_matching_enabled = true
    and (q.age_band = 'adult' or q.guardian_approved = true)
    and not exists (
      select 1 from public.body_double_user_restrictions r
      where r.user_id = q.user_id
        and r.status = 'active'
        and r.restriction_type in ('random_suspended', 'body_double_suspended')
        and r.starts_at <= now()
        and (r.expires_at is null or r.expires_at > now())
    )
    -- Prevent blocked combinations
    and not exists (
      select 1 from public.user_blocks b 
      where (b.blocker_id = v_my_entry.user_id and b.blocked_id = q.user_id)
         or (b.blocker_id = q.user_id and b.blocked_id = v_my_entry.user_id)
    )
  order by q.created_at asc
  limit 1
  for update skip locked;

  if found then
    -- Create session
    insert into public.body_double_sessions (
      user_id,
      mode,
      status,
      session_type,
      session_length_minutes,
      communication_mode,
      privacy_level,
      started_at
    )
    values (
      v_my_entry.user_id,
      'random',
      'active',
      v_my_entry.session_type,
      v_my_entry.session_length_minutes,
      v_my_entry.communication_mode,
      case
        when v_my_entry.privacy_level = 'private' then 'private'
        else 'titleOnly'
      end,
      now()
    )
    returning id into v_session_id;

    -- Add participants
    insert into public.body_double_participants (
      session_id, user_id, role, status, age_band_snapshot, anonymous_label, joined_at
    )
    values (v_session_id, v_my_entry.user_id, 'random', 'active', v_my_entry.age_band, 'Body double A', now());
    insert into public.body_double_participants (
      session_id, user_id, role, status, age_band_snapshot, anonymous_label, joined_at
    )
    values (v_session_id, v_match_entry.user_id, 'random', 'active', v_match_entry.age_band, 'Body double B', now());

    -- Update queue entries
    update public.body_double_queue set status = 'matched', matched_session_id = v_session_id where id = p_queue_id;
    update public.body_double_queue set status = 'matched', matched_session_id = v_session_id where id = v_match_entry.id;

    insert into public.body_double_audit_events(actor_id, session_id, queue_id, event_type, metadata)
    values
      (v_my_entry.user_id, v_session_id, v_my_entry.id, 'random_match_created', jsonb_build_object('age_band', v_my_entry.age_band, 'communication_mode', v_my_entry.communication_mode)),
      (v_match_entry.user_id, v_session_id, v_match_entry.id, 'random_match_created', jsonb_build_object('age_band', v_match_entry.age_band, 'communication_mode', v_match_entry.communication_mode));

    return v_session_id;
  end if;

  return null;
end;
$$;
