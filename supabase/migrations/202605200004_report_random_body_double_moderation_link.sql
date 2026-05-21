-- Phase 3D/3E verification fix:
-- Ensure report_random_body_double_session always creates a linked
-- body_double_message_moderation_events row for report triage.
--
-- This migration intentionally runs late so it wins over earlier Phase 3
-- random/body-double migrations.

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
  v_reason text := coalesce(nullif(trim(p_reason), ''), 'Safety concern');
  v_details text := nullif(trim(coalesce(p_details, '')), '');
begin
  if v_reporter_id is null then
    raise exception 'Not authenticated';
  end if;

  if p_session_id is null then
    raise exception 'Session id is required';
  end if;

  if p_reported_user_id is null then
    raise exception 'Reported user id is required';
  end if;

  if p_reported_user_id = v_reporter_id then
    raise exception 'Users cannot report themselves';
  end if;

  if not exists (
    select 1
    from public.body_double_sessions s
    where s.id = p_session_id
      and s.mode = 'random'
  ) then
    raise exception 'Can only report random body double sessions through this RPC';
  end if;

  if not exists (
    select 1
    from public.body_double_participants p
    where p.session_id = p_session_id
      and p.user_id = v_reporter_id
  ) then
    raise exception 'Reporter is not a session participant';
  end if;

  if not exists (
    select 1
    from public.body_double_participants p
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
    v_reason,
    v_details
  )
  returning id into v_report_id;

  insert into public.user_blocks(blocker_id, blocked_id)
  values (v_reporter_id, p_reported_user_id)
  on conflict do nothing;

  insert into public.body_double_message_moderation_events (
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
    v_reason,
    left(coalesce(v_details, v_reason), 80)
  );

  update public.body_double_sessions
  set
    status = 'reported',
    ended_at = coalesce(ended_at, now()),
    updated_at = now()
  where id = p_session_id
    and mode = 'random';

  update public.body_double_participants
  set
    status = 'left',
    left_at = coalesce(left_at, now()),
    updated_at = now()
  where session_id = p_session_id
    and user_id = v_reporter_id;

  insert into public.body_double_audit_events (
    actor_id,
    session_id,
    event_type,
    metadata
  )
  values (
    v_reporter_id,
    p_session_id,
    'random_session_reported',
    jsonb_build_object(
      'reported_user_id', p_reported_user_id,
      'report_id', v_report_id,
      'reason', v_reason,
      'moderation_event_created', true
    )
  );

  return v_report_id;
end;
$$;

select pg_notify('pgrst', 'reload schema');
