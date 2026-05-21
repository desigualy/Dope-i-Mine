-- Phase 3D/3E verification fix:
-- Persist moderation events for blocked random text attempts.
-- PostgreSQL rolls back writes made inside a function when that same function
-- raises an exception, so blocked-message moderation rows cannot persist if the
-- RPC raises after inserting them. This function returns null for filtered or
-- rate-limited text after recording the moderation/audit event. It still raises
-- for authentication/session/permission failures.

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
    left join public.body_double_random_safety_settings settings
      on settings.user_id = v_sender_id
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
    select 1
    from public.body_double_messages m
    where m.session_id = p_session_id
      and m.sender_id = v_sender_id
      and m.created_at > now() - interval '10 seconds'
  ) then
    insert into public.body_double_message_moderation_events(
      session_id,
      sender_id,
      action,
      reason,
      body_preview
    ) values (
      p_session_id,
      v_sender_id,
      'blocked',
      'rate_limited',
      left(v_clean_body, 80)
    );

    insert into public.body_double_audit_events(
      actor_id,
      session_id,
      event_type,
      metadata
    ) values (
      v_sender_id,
      p_session_id,
      'random_text_message_blocked',
      jsonb_build_object('reason', 'rate_limited')
    );

    return null;
  end if;

  v_reason := public.body_double_random_text_block_reason(v_clean_body);

  if v_reason is not null then
    insert into public.body_double_message_moderation_events(
      session_id,
      sender_id,
      action,
      reason,
      body_preview
    ) values (
      p_session_id,
      v_sender_id,
      'blocked',
      v_reason,
      left(v_clean_body, 80)
    );

    insert into public.body_double_audit_events(
      actor_id,
      session_id,
      event_type,
      metadata
    ) values (
      v_sender_id,
      p_session_id,
      'random_text_message_blocked',
      jsonb_build_object('reason', v_reason)
    );

    return null;
  end if;

  insert into public.body_double_messages(
    session_id,
    sender_id,
    message_type,
    body
  ) values (
    p_session_id,
    v_sender_id,
    'text',
    v_clean_body
  )
  returning id into v_message_id;

  insert into public.body_double_message_moderation_events(
    session_id,
    sender_id,
    message_id,
    action,
    reason,
    body_preview
  ) values (
    p_session_id,
    v_sender_id,
    v_message_id,
    'allowed',
    'passed_filter',
    left(v_clean_body, 80)
  );

  insert into public.body_double_audit_events(
    actor_id,
    session_id,
    event_type,
    metadata
  ) values (
    v_sender_id,
    p_session_id,
    'random_text_message_sent',
    jsonb_build_object(
      'message_id', v_message_id,
      'length', length(v_clean_body)
    )
  );

  return v_message_id;
end;
$$;

select pg_notify('pgrst', 'reload schema');
