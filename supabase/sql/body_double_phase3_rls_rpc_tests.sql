-- Local verification for Body Double Phase 3A/3B/3C RLS/RPC safety.
-- Run only against a disposable local Supabase/Postgres database after applying
-- migrations through 202605090001_body_double_phase3_random.sql.
--
-- Example:
--   psql "$SUPABASE_DB_URL" -v ON_ERROR_STOP=1 \
--     -f supabase/sql/body_double_phase3_rls_rpc_tests.sql

begin;

do $$
declare
  adult_a uuid := '00000000-0000-0000-0000-0000000000a1';
  adult_b uuid := '00000000-0000-0000-0000-0000000000a2';
  teen_a uuid := '00000000-0000-0000-0000-0000000000b1';
  teen_b uuid := '00000000-0000-0000-0000-0000000000b2';
  queue_adult_a uuid;
  queue_adult_b uuid;
  queue_teen_b uuid;
  matched_session_id uuid;
  text_session_id uuid;
  text_message_id uuid;
  linked_report_id uuid;
  stale_session_id uuid;
  blocked_session_id uuid;
  group_session_id uuid;
  adult_c uuid := '00000000-0000-0000-0000-0000000000a3';
  adult_eligible boolean;
  teen_eligible boolean;
  lifecycle_result record;
  retention_result record;
  restriction_id uuid;
begin
  -- Minimal local auth/profile fixtures. Supabase auth.users column names vary
  -- by local CLI/auth schema version, so this targets the columns present in
  -- current Supabase local images (confirmed_at, not email_confirmed_at).
  insert into auth.users (
    id,
    aud,
    role,
    email,
    encrypted_password,
    confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at
  )
  values
    (adult_a, 'authenticated', 'authenticated', 'bd-adult-a@example.test', crypt('password', gen_salt('bf')), now(), '{}'::jsonb, '{}'::jsonb, now(), now()),
    (adult_b, 'authenticated', 'authenticated', 'bd-adult-b@example.test', crypt('password', gen_salt('bf')), now(), '{}'::jsonb, '{}'::jsonb, now(), now()),
    (adult_c, 'authenticated', 'authenticated', 'bd-adult-c@example.test', crypt('password', gen_salt('bf')), now(), '{}'::jsonb, '{}'::jsonb, now(), now()),
    (teen_a, 'authenticated', 'authenticated', 'bd-teen-a@example.test', crypt('password', gen_salt('bf')), now(), '{}'::jsonb, '{}'::jsonb, now(), now()),
    (teen_b, 'authenticated', 'authenticated', 'bd-teen-b@example.test', crypt('password', gen_salt('bf')), now(), '{}'::jsonb, '{}'::jsonb, now(), now())
  on conflict (id) do nothing;

  insert into public.users_profile (id, email, age_band, onboarding_completed)
  values
    (adult_a, 'bd-adult-a@example.test', 'adult', true),
    (adult_b, 'bd-adult-b@example.test', 'adult', true),
    (adult_c, 'bd-adult-c@example.test', 'adult', true),
    (teen_a, 'bd-teen-a@example.test', 'teen', true),
    (teen_b, 'bd-teen-b@example.test', 'teen', true)
  on conflict (id) do update set age_band = excluded.age_band;

  insert into public.body_double_moderators(user_id)
  values (adult_a)
  on conflict (user_id) do nothing;

  insert into public.body_double_random_safety_settings (
    user_id,
    random_matching_enabled,
    guardian_random_approved,
    preset_signals_allowed,
    quiet_mode_allowed,
    text_allowed
  )
  values
    (adult_a, true, false, true, true, true, true),
    (adult_b, true, false, true, true, true, true),
    (adult_c, true, false, true, true, true, true),
    (teen_a, true, false, true, true, false, false),
    (teen_b, true, true, true, true, false, false)
  on conflict (user_id) do update set
    random_matching_enabled = excluded.random_matching_enabled,
    guardian_random_approved = excluded.guardian_random_approved,
    preset_signals_allowed = excluded.preset_signals_allowed,
    quiet_mode_allowed = excluded.quiet_mode_allowed,
    text_allowed = excluded.text_allowed;

  perform set_config('request.jwt.claim.sub', adult_a::text, true);
  perform set_config('role', 'authenticated', true);
  select can_enter_random_queue into adult_eligible
  from public.get_random_body_double_eligibility(adult_a);
  if adult_eligible is not true then
    raise exception 'Expected adult with enabled settings to be eligible';
  end if;

  perform set_config('request.jwt.claim.sub', teen_a::text, true);
  select can_enter_random_queue into teen_eligible
  from public.get_random_body_double_eligibility(teen_a);
  if teen_eligible is true then
    raise exception 'Expected teen without guardian approval to be ineligible';
  end if;

  begin
    perform public.enter_random_body_double_queue('focusSprint', 'study', 25, 'presetSignals', 'private');
    raise exception 'Teen without guardian approval entered queue unexpectedly';
  exception when others then
    if sqlerrm not like '%not enabled%' then
      raise;
    end if;
  end;

  perform set_config('request.jwt.claim.sub', adult_a::text, true);
  queue_adult_a := public.enter_random_body_double_queue('focusSprint', 'admin', 25, 'presetSignals', 'private');

  perform set_config('request.jwt.claim.sub', teen_b::text, true);
  queue_teen_b := public.enter_random_body_double_queue('focusSprint', 'study', 25, 'presetSignals', 'private');

  perform set_config('request.jwt.claim.sub', adult_a::text, true);
  matched_session_id := public.find_body_double_match(queue_adult_a);
  if matched_session_id is not null then
    raise exception 'Adult matched with teen unexpectedly';
  end if;

  perform set_config('request.jwt.claim.sub', adult_b::text, true);
  queue_adult_b := public.enter_random_body_double_queue('focusSprint', 'admin', 25, 'presetSignals', 'private');

  perform set_config('request.jwt.claim.sub', adult_a::text, true);
  matched_session_id := public.find_body_double_match(queue_adult_a);
  if matched_session_id is null then
    raise exception 'Expected compatible adults to match';
  end if;
  stale_session_id := matched_session_id;

  begin
    insert into public.body_double_messages(session_id, sender_id, message_type, body)
    values (matched_session_id, adult_a, 'text', 'hello');
    raise exception 'Random free-text message inserted unexpectedly';
  exception when others then
    if sqlerrm not like '%row-level security%' and sqlerrm not like '%violates%' then
      raise;
    end if;
  end;

  insert into public.body_double_messages(session_id, sender_id, message_type, body)
  values (matched_session_id, adult_a, 'preset', 'Still here');

  -- Phase 3C: random text is adult-only, opt-in, RPC-only, filtered, audited,
  -- and rate limited. Minors remain preset/quiet only even with guardian approval.
  begin
    perform public.enter_random_body_double_queue('focusSprint', 'study', 25, 'voice', 'private');
    raise exception 'Minor entered random voice queue unexpectedly';
  exception when others then
    if position('adult-only' in lower(sqlerrm)) = 0 then
      raise;
    end if;
  end;

  perform set_config('request.jwt.claim.sub', adult_a::text, true);
  queue_adult_a := public.enter_random_body_double_queue('focusSprint', 'admin', 25, 'textOnly', 'private');
  perform set_config('request.jwt.claim.sub', adult_b::text, true);
  queue_adult_b := public.enter_random_body_double_queue('focusSprint', 'admin', 25, 'textOnly', 'private');
  perform set_config('request.jwt.claim.sub', adult_a::text, true);
  text_session_id := public.find_body_double_match(queue_adult_a);
  if text_session_id is null then
    raise exception 'Expected compatible opted-in adults to match for textOnly';
  end if;

  begin
    insert into public.body_double_messages(session_id, sender_id, message_type, body)
    values (text_session_id, adult_a, 'text', 'direct text insert should fail');
    raise exception 'Direct random text insert bypassed RPC unexpectedly';
  exception when others then
    if sqlerrm not like '%row-level security%' and sqlerrm not like '%violates%' then
      raise;
    end if;
  end;

  begin
    perform public.send_random_body_double_text_message(text_session_id, 'Visit https://example.com');
    raise exception 'Unsafe random text link was sent unexpectedly';
  exception when others then
    if sqlerrm not like '%link%' then
      raise;
    end if;
  end;
  if not exists (
    select 1 from public.body_double_message_moderation_events
    where session_id = text_session_id
      and sender_id = adult_a
      and action = 'blocked'
      and reason = 'link'
  ) then
    raise exception 'Expected blocked link moderation event';
  end if;

  text_message_id := public.send_random_body_double_text_message(
    text_session_id,
    'Still here and starting step one'
  );
  if not exists (
    select 1 from public.body_double_message_moderation_events
    where session_id = text_session_id
      and message_id = text_message_id
      and action = 'allowed'
  ) then
    raise exception 'Expected allowed text moderation event';
  end if;

  begin
    perform public.send_random_body_double_text_message(text_session_id, 'Second message too soon');
    raise exception 'Random text rate limit did not trigger';
  exception when others then
    if sqlerrm not like '%rate limited%' then
      raise;
    end if;
  end;

  perform set_config('request.jwt.claim.sub', adult_b::text, true);
  linked_report_id := public.report_random_body_double_session(
    text_session_id,
    adult_a,
    'Unsafe random text',
    'Local verification report preview'
  );
  if not exists (
    select 1 from public.user_reports r
    where r.id = linked_report_id
      and r.session_id = text_session_id
      and r.reporter_id = adult_b
      and r.reported_id = adult_a
  ) then
    raise exception 'Expected report RPC to create linked user report';
  end if;
  if not exists (
    select 1 from public.body_double_message_moderation_events e
    where e.session_id = text_session_id
      and e.sender_id = adult_a
      and e.report_id = linked_report_id
      and e.action = 'reported'
  ) then
    raise exception 'Expected reported moderation event linked to user report';
  end if;

  perform set_config('request.jwt.claim.sub', adult_a::text, true);
  update public.body_double_message_moderation_events
  set created_at = now() - interval '31 days'
  where message_id = text_message_id;
  select * into retention_result
  from public.cleanup_body_double_moderation_retention(
    interval '30 days',
    interval '90 days',
    interval '180 days',
    interval '1 year'
  );
  if retention_result.allowed_previews_scrubbed < 1 then
    raise exception 'Expected retention cleanup to scrub aged allowed preview';
  end if;
  if exists (
    select 1 from public.body_double_message_moderation_events
    where message_id = text_message_id
      and body_preview is not null
  ) then
    raise exception 'Expected aged allowed body preview to be removed';
  end if;

  perform set_config('request.jwt.claim.sub', adult_a::text, true);
  perform public.body_double_presence_heartbeat(matched_session_id, 'active');
  update public.body_double_presence
  set updated_at = now() - interval '3 minutes'
  where body_double_presence.session_id = stale_session_id
    and body_double_presence.user_id = adult_a;

  select * into lifecycle_result
  from public.cleanup_body_double_random_lifecycle(
    interval '5 minutes',
    interval '2 minutes'
  );
  if lifecycle_result.stale_presence < 1 then
    raise exception 'Expected stale random presence heartbeat to timeout';
  end if;

  -- Block prevents future matching.
  insert into public.user_blocks(blocker_id, blocked_id)
  values (adult_a, adult_b)
  on conflict do nothing;

  perform set_config('request.jwt.claim.sub', adult_a::text, true);
  queue_adult_a := public.enter_random_body_double_queue('focusSprint', 'admin', 25, 'presetSignals', 'private');
  perform set_config('request.jwt.claim.sub', adult_b::text, true);
  queue_adult_b := public.enter_random_body_double_queue('focusSprint', 'admin', 25, 'presetSignals', 'private');
  perform set_config('request.jwt.claim.sub', adult_a::text, true);
  blocked_session_id := public.find_body_double_match(queue_adult_a);
  if blocked_session_id is not null then
    raise exception 'Blocked users matched unexpectedly';
  end if;

  -- Moderator review queue and user restriction workflow.
  insert into public.user_reports(reporter_id, reported_id, session_id, reason, details)
  values (adult_a, adult_b, matched_session_id, 'Unsafe signal', 'Local verification report')
  returning id into restriction_id;

  perform set_config('request.jwt.claim.sub', adult_a::text, true);
  perform public.review_body_double_report(restriction_id, 'reviewed');
  restriction_id := public.restrict_body_double_user(
    adult_b,
    'random_suspended',
    'Local verification suspension',
    now() + interval '1 hour',
    restriction_id
  );

  perform set_config('request.jwt.claim.sub', adult_b::text, true);
  select can_enter_random_queue into adult_eligible
  from public.get_random_body_double_eligibility(adult_b);
  if adult_eligible is true then
    raise exception 'Restricted user remained eligible for random matching';
  end if;

  perform set_config('request.jwt.claim.sub', adult_a::text, true);
  perform public.revoke_body_double_user_restriction(restriction_id, 'Local verification cleanup');

  perform set_config('request.jwt.claim.sub', teen_b::text, true);
  perform public.cancel_random_body_double_queue(queue_teen_b);
  if not exists (
    select 1 from public.body_double_queue
    where id = queue_teen_b and status = 'cancelled'
  ) then
    raise exception 'Expected queue cancellation to persist';
  end if;

  -- Phase 3D: Group Matching Verification
  perform set_config('request.jwt.claim.sub', adult_a::text, true);
  queue_adult_a := public.enter_random_body_double_queue('focusSprint', 'admin', 25, 'presetSignals', 'private');
  perform set_config('request.jwt.claim.sub', adult_b::text, true);
  queue_adult_b := public.enter_random_body_double_queue('focusSprint', 'admin', 25, 'presetSignals', 'private');
  perform set_config('request.jwt.claim.sub', adult_a::text, true);
  group_session_id := public.find_body_double_match(queue_adult_a); -- Creates session with A and B
  
  perform set_config('request.jwt.claim.sub', adult_c::text, true);
  restriction_id := public.enter_random_body_double_queue('focusSprint', 'admin', 25, 'presetSignals', 'private');
  matched_session_id := public.find_body_double_match(restriction_id); -- Should join existing group session
  
  if matched_session_id != group_session_id then
    raise exception 'Expected user C to join existing group session';
  end if;
  
  if (select count(*) from public.body_double_participants where session_id = group_session_id) != 3 then
    raise exception 'Expected 3 participants in group session';
  end if;

  -- Phase 3F: Reliability Penalty Verification
  perform set_config('request.jwt.claim.sub', adult_a::text, true);
  perform public.review_body_double_report(linked_report_id, 'actioned');
  
  if (select reliability_score from public.users_profile where id = adult_a) >= 1.0 then
    raise exception 'Expected reliability penalty for actioned report';
  end if;
end $$;

rollback;