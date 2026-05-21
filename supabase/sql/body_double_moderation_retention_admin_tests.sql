-- Admin-only verification for body-double moderation retention cleanup.
-- Separate from body_double_phase3_rls_rpc_tests.sql by design.

begin;

do $$
declare
  v_moderator_id uuid := '10000000-0000-0000-0000-000000000001';
  v_reported_user_id uuid := '10000000-0000-0000-0000-000000000002';
  v_session_id uuid;
  v_allowed_event_id uuid;
  v_blocked_event_id uuid;
  v_reported_event_id uuid;
  v_cleanup_result record;
begin
  insert into auth.users (
    id, aud, role, email, encrypted_password, email_confirmed_at,
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
  )
  values
    (
      v_moderator_id, 'authenticated', 'authenticated',
      'phase3-retention-moderator@example.test',
      crypt('password', gen_salt('bf')), now(), '{}'::jsonb, '{}'::jsonb, now(), now()
    ),
    (
      v_reported_user_id, 'authenticated', 'authenticated',
      'phase3-retention-user@example.test',
      crypt('password', gen_salt('bf')), now(), '{}'::jsonb, '{}'::jsonb, now(), now()
    )
  on conflict (id) do nothing;

  insert into public.users_profile (
    id, email, display_name, age_band, onboarding_completed, created_at, updated_at
  )
  values
    (
      v_moderator_id, 'phase3-retention-moderator@example.test',
      'Retention Moderator', 'adult', true, now(), now()
    ),
    (
      v_reported_user_id, 'phase3-retention-user@example.test',
      'Retention User', 'adult', true, now(), now()
    )
  on conflict (id) do update set
    age_band = excluded.age_band,
    onboarding_completed = excluded.onboarding_completed,
    updated_at = now();

  insert into public.body_double_moderators(user_id)
  values (v_moderator_id)
  on conflict (user_id) do nothing;

  insert into public.body_double_sessions (
    user_id, mode, status, session_type, session_length_minutes,
    communication_mode, privacy_level, started_at, created_at, updated_at
  )
  values (
    v_moderator_id, 'random', 'completed', 'focusSprint', 25,
    'textOnly', 'private', now() - interval '200 days',
    now() - interval '200 days', now() - interval '200 days'
  )
  returning id into v_session_id;

  insert into public.body_double_message_moderation_events (
    session_id, sender_id, action, reason, body_preview, created_at
  )
  values
    (
      v_session_id, v_moderator_id, 'allowed', 'retention_admin_fixture',
      'Allowed preview should be scrubbed', now() - interval '31 days'
    )
  returning id into v_allowed_event_id;

  insert into public.body_double_message_moderation_events (
    session_id, sender_id, action, reason, body_preview, created_at
  )
  values
    (
      v_session_id, v_moderator_id, 'blocked', 'retention_admin_fixture',
      'Blocked preview should be scrubbed', now() - interval '91 days'
    )
  returning id into v_blocked_event_id;

  insert into public.body_double_message_moderation_events (
    session_id, sender_id, action, reason, body_preview, created_at
  )
  values
    (
      v_session_id, v_reported_user_id, 'reported', 'retention_admin_fixture',
      'Reported preview should be scrubbed after review', now() - interval '181 days'
    )
  returning id into v_reported_event_id;

  perform set_config('request.jwt.claim.sub', v_moderator_id::text, true);

  select * into v_cleanup_result
  from public.cleanup_body_double_moderation_retention(
    interval '30 days',
    interval '90 days',
    interval '180 days',
    interval '1 year'
  );

  if v_cleanup_result.allowed_previews_scrubbed < 1 then
    raise exception 'Expected admin retention cleanup to scrub aged allowed preview';
  end if;

  if v_cleanup_result.blocked_previews_scrubbed < 1 then
    raise exception 'Expected admin retention cleanup to scrub aged blocked preview';
  end if;

  if v_cleanup_result.reported_previews_scrubbed < 1 then
    raise exception 'Expected admin retention cleanup to scrub aged reported preview';
  end if;

  if exists (
    select 1
    from public.body_double_message_moderation_events e
    where e.id in (v_allowed_event_id, v_blocked_event_id, v_reported_event_id)
      and e.body_preview is not null
  ) then
    raise exception 'Expected all aged moderation previews to be scrubbed';
  end if;
end $$;

rollback;
