-- Phase 3D/3E late hardening:
-- Force-replace the random body-double report RPC and assert that the
-- linked moderation event is created before returning.
--
-- This migration intentionally runs after all earlier body-double random
-- migrations so no older function body can win.

drop function if exists public.report_random_body_double_session(uuid, uuid, text, text);

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
  v_reported_event_id uuid;
begin
  if v_reporter_id is null then
    raise exception 'Not authenticated';
  end if;

  if v_reporter_id = p_reported_user_id then
    raise exception 'Reporter cannot report themselves';
  end if;

  if not exists (
    select 1
    from public.body_double_sessions s
    join public.body_double_participants p
      on p.session_id = s.id
    where s.id = p_session_id
      and s.mode = 'random'
      and p.user_id = v_reporter_id
      and p.status in ('accepted', 'active')
  ) then
    raise exception 'Reporter is not an active random session participant';
  end if;

  if not exists (
    select 1
    from public.body_double_sessions s
    join public.body_double_participants p
      on p.session_id = s.id
    where s.id = p_session_id
      and s.mode = 'random'
      and p.user_id = p_reported_user_id
      and p.status in ('accepted', 'active')
  ) then
    raise exception 'Reported user is not an active random session participant';
  end if;

  insert into public.user_reports (
    reporter_id,
    reported_id,
    session_id,
    reason,
    details,
    status,
    created_at
  )
  values (
    v_reporter_id,
    p_reported_user_id,
    p_session_id,
    v_reason,
    v_details,
    'pending',
    now()
  )
  returning id into v_report_id;

  -- Reporting a random participant also blocks them for the reporter.
  insert into public.user_blocks (
    blocker_id,
    blocked_id,
    created_at
  )
  values (
    v_reporter_id,
    p_reported_user_id,
    now()
  )
  on conflict (blocker_id, blocked_id) do nothing;

  insert into public.body_double_message_moderation_events (
    session_id,
    sender_id,
    report_id,
    action,
    reason,
    body_preview,
    created_at
  )
  values (
    p_session_id,
    p_reported_user_id,
    v_report_id,
    'reported',
    v_reason,
    left(coalesce(v_details, v_reason), 80),
    now()
  )
  returning id into v_reported_event_id;

  if v_reported_event_id is null then
    raise exception 'Failed to create linked reported moderation event';
  end if;

  if not exists (
    select 1
    from public.body_double_message_moderation_events e
    where e.id = v_reported_event_id
      and e.session_id = p_session_id
      and e.sender_id = p_reported_user_id
      and e.report_id = v_report_id
      and e.action = 'reported'
  ) then
    raise exception 'Linked reported moderation event verification failed';
  end if;

  update public.body_double_sessions
  set
    status = 'reported',
    ended_at = coalesce(ended_at, now()),
    updated_at = now(),
    summary = coalesce(summary, 'Random body double session was reported and closed for safety.')
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
    metadata,
    created_at
  )
  values (
    v_reporter_id,
    p_session_id,
    'random_session_reported',
    jsonb_build_object(
      'reported_user_id', p_reported_user_id,
      'report_id', v_report_id,
      'moderation_event_id', v_reported_event_id,
      'reason', v_reason
    ),
    now()
  );

  return v_report_id;
end;
$$;

select pg_notify('pgrst', 'reload schema');
