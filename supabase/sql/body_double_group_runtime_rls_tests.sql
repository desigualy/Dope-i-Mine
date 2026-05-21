-- Phase 3G group body-double runtime RLS/RPC verification.

begin;

do $$
declare
  v_adult_a uuid := '30000000-0000-0000-0000-000000000001';
  v_adult_b uuid := '30000000-0000-0000-0000-000000000002';
  v_adult_c uuid := '30000000-0000-0000-0000-000000000003';
  v_adult_d uuid := '30000000-0000-0000-0000-000000000004';
  v_minor uuid := '30000000-0000-0000-0000-000000000005';
  v_blocked uuid := '30000000-0000-0000-0000-000000000006';
  v_restricted uuid := '30000000-0000-0000-0000-000000000007';
  v_queue_a uuid;
  v_queue_b uuid;
  v_queue_c uuid;
  v_queue_d uuid;
  v_session_id uuid;
  v_report_id uuid;
  v_count integer;
begin
  insert into auth.users (id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
  values
    (v_adult_a, 'authenticated', 'authenticated', 'phase3g-a@example.test', crypt('password', gen_salt('bf')), now(), '{}'::jsonb, '{}'::jsonb, now(), now()),
    (v_adult_b, 'authenticated', 'authenticated', 'phase3g-b@example.test', crypt('password', gen_salt('bf')), now(), '{}'::jsonb, '{}'::jsonb, now(), now()),
    (v_adult_c, 'authenticated', 'authenticated', 'phase3g-c@example.test', crypt('password', gen_salt('bf')), now(), '{}'::jsonb, '{}'::jsonb, now(), now()),
    (v_adult_d, 'authenticated', 'authenticated', 'phase3g-d@example.test', crypt('password', gen_salt('bf')), now(), '{}'::jsonb, '{}'::jsonb, now(), now()),
    (v_minor, 'authenticated', 'authenticated', 'phase3g-minor@example.test', crypt('password', gen_salt('bf')), now(), '{}'::jsonb, '{}'::jsonb, now(), now()),
    (v_blocked, 'authenticated', 'authenticated', 'phase3g-blocked@example.test', crypt('password', gen_salt('bf')), now(), '{}'::jsonb, '{}'::jsonb, now(), now()),
    (v_restricted, 'authenticated', 'authenticated', 'phase3g-restricted@example.test', crypt('password', gen_salt('bf')), now(), '{}'::jsonb, '{}'::jsonb, now(), now())
  on conflict (id) do nothing;

  insert into public.users_profile (id, email, display_name, age_band, onboarding_completed, created_at, updated_at)
  values
    (v_adult_a, 'phase3g-a@example.test', 'A', 'adult', true, now(), now()),
    (v_adult_b, 'phase3g-b@example.test', 'B', 'adult', true, now(), now()),
    (v_adult_c, 'phase3g-c@example.test', 'C', 'adult', true, now(), now()),
    (v_adult_d, 'phase3g-d@example.test', 'D', 'adult', true, now(), now()),
    (v_minor, 'phase3g-minor@example.test', 'Minor', 'teen', true, now(), now()),
    (v_blocked, 'phase3g-blocked@example.test', 'Blocked', 'adult', true, now(), now()),
    (v_restricted, 'phase3g-restricted@example.test', 'Restricted', 'adult', true, now(), now())
  on conflict (id) do update set age_band = excluded.age_band, onboarding_completed = true, updated_at = now();

  insert into public.body_double_random_safety_settings(user_id, random_matching_enabled, preset_signals_allowed, quiet_mode_allowed, text_allowed, voice_allowed)
  values
    (v_adult_a, true, true, true, false, false),
    (v_adult_b, true, true, true, false, false),
    (v_adult_c, true, true, true, false, false),
    (v_adult_d, true, true, true, false, false),
    (v_blocked, true, true, true, false, false),
    (v_restricted, true, true, true, false, false),
    (v_minor, true, true, true, false, false)
  on conflict (user_id) do update set random_matching_enabled = true, preset_signals_allowed = true, quiet_mode_allowed = true, text_allowed = false, voice_allowed = false;

  insert into public.body_double_user_restrictions(user_id, restriction_type, reason)
  values (v_restricted, 'random_suspended', 'Phase 3G test restriction');

  perform set_config('role', 'authenticated', true);

  perform set_config('request.jwt.claim.sub', v_minor::text, true);
  begin
    perform public.enter_group_body_double_queue('focusSprint', 'study', 25, 'presetSignals', 'titleOnly', 3);
    raise exception 'Minor entered random group unexpectedly';
  exception when others then
    if position('adult' in lower(sqlerrm)) = 0 then raise; end if;
  end;

  perform set_config('request.jwt.claim.sub', v_restricted::text, true);
  begin
    perform public.enter_group_body_double_queue('focusSprint', 'focus', 25, 'presetSignals', 'titleOnly', 3);
    raise exception 'Restricted user entered random group unexpectedly';
  exception when others then
    if position('restricted' in lower(sqlerrm)) = 0 then raise; end if;
  end;

  perform set_config('request.jwt.claim.sub', v_adult_a::text, true);
  v_queue_a := public.enter_group_body_double_queue('focusSprint', 'focus', 25, 'presetSignals', 'titleOnly', 3);
  v_session_id := public.find_group_body_double_match(v_queue_a);
  if v_session_id is null then raise exception 'Adult A should create waiting random group'; end if;

  select count(*) into v_count from public.body_double_sessions where id = v_session_id;
  if v_count <> 1 then raise exception 'Participant should read own group session'; end if;

  perform set_config('request.jwt.claim.sub', v_adult_d::text, true);
  select count(*) into v_count from public.body_double_sessions where id = v_session_id;
  if v_count <> 0 then raise exception 'Non-participant read group session'; end if;

  perform set_config('request.jwt.claim.sub', v_adult_b::text, true);
  v_queue_b := public.enter_group_body_double_queue('focusSprint', 'focus', 25, 'presetSignals', 'titleOnly', 3);
  if public.find_group_body_double_match(v_queue_b) <> v_session_id then
    raise exception 'Compatible adult B should join existing group';
  end if;
  if not exists (select 1 from public.body_double_sessions where id = v_session_id and current_participant_count = 2 and status = 'active') then
    raise exception 'Group should start at two participants';
  end if;

  perform set_config('request.jwt.claim.sub', v_adult_a::text, true);
  begin
    perform public.find_group_body_double_match(v_queue_a);
    if (select count(*) from public.body_double_participants where session_id = v_session_id and user_id = v_adult_a) > 1 then
      raise exception 'Same user joined group twice';
    end if;
  exception when others then
    if position('twice' in lower(sqlerrm)) > 0 then raise; end if;
  end;

  perform set_config('request.jwt.claim.sub', v_adult_c::text, true);
  v_queue_c := public.enter_group_body_double_queue('focusSprint', 'focus', 25, 'presetSignals', 'titleOnly', 3);
  if public.find_group_body_double_match(v_queue_c) <> v_session_id then
    raise exception 'Compatible adult C should fill group';
  end if;
  if exists (select 1 from public.body_double_sessions where id = v_session_id and current_participant_count > 3) then
    raise exception 'Group exceeded max size';
  end if;

  perform set_config('request.jwt.claim.sub', v_blocked::text, true);
  insert into public.user_blocks(blocker_id, blocked_id) values (v_blocked, v_adult_a) on conflict do nothing;
  v_queue_d := public.enter_group_body_double_queue('focusSprint', 'focus', 25, 'presetSignals', 'titleOnly', 3);
  if public.find_group_body_double_match(v_queue_d) = v_session_id then
    raise exception 'Blocked user joined incompatible group';
  end if;

  perform set_config('request.jwt.claim.sub', v_adult_b::text, true);
  perform public.leave_group_body_double_session(v_session_id);
  if not exists (select 1 from public.body_double_participants where session_id = v_session_id and user_id = v_adult_b and status = 'left') then
    raise exception 'Participant leave did not update participant status';
  end if;

  perform set_config('request.jwt.claim.sub', v_adult_a::text, true);
  v_report_id := public.report_random_body_double_session(v_session_id, v_adult_c, 'Safety concern', 'Phase 3G group report');
  if not exists (select 1 from public.user_reports where id = v_report_id and session_id = v_session_id) then
    raise exception 'Group report was not created';
  end if;
  if not exists (select 1 from public.body_double_audit_events where session_id = v_session_id and event_type like '%report%') then
    raise exception 'Group report audit/moderation event missing';
  end if;
end $$;

rollback;