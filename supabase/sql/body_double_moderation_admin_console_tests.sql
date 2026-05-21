-- Admin console verification for Phase 3F body-double moderation operations.
-- Keep separate from body_double_phase3_rls_rpc_tests.sql so app-user runtime
-- safety checks do not depend on admin retention/moderation fixtures.

begin;

do $$
declare
  v_moderator_id uuid := '20000000-0000-0000-0000-000000000001';
  v_reporter_id uuid := '20000000-0000-0000-0000-000000000002';
  v_reported_id uuid := '20000000-0000-0000-0000-000000000003';
  v_other_user_id uuid := '20000000-0000-0000-0000-000000000004';
  v_session_id uuid;
  v_report_id uuid;
  v_restriction_id uuid;
  v_can_read integer;
begin
  insert into auth.users (
    id, aud, role, email, encrypted_password, email_confirmed_at,
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
  )
  values
    (v_moderator_id, 'authenticated', 'authenticated', 'phase3f-moderator@example.test', crypt('password', gen_salt('bf')), now(), '{}'::jsonb, '{}'::jsonb, now(), now()),
    (v_reporter_id, 'authenticated', 'authenticated', 'phase3f-reporter@example.test', crypt('password', gen_salt('bf')), now(), '{}'::jsonb, '{}'::jsonb, now(), now()),
    (v_reported_id, 'authenticated', 'authenticated', 'phase3f-reported@example.test', crypt('password', gen_salt('bf')), now(), '{}'::jsonb, '{}'::jsonb, now(), now()),
    (v_other_user_id, 'authenticated', 'authenticated', 'phase3f-other@example.test', crypt('password', gen_salt('bf')), now(), '{}'::jsonb, '{}'::jsonb, now(), now())
  on conflict (id) do nothing;

  insert into public.users_profile (id, email, display_name, age_band, onboarding_completed, created_at, updated_at)
  values
    (v_moderator_id, 'phase3f-moderator@example.test', 'Moderator', 'adult', true, now(), now()),
    (v_reporter_id, 'phase3f-reporter@example.test', 'Reporter', 'adult', true, now(), now()),
    (v_reported_id, 'phase3f-reported@example.test', 'Reported', 'adult', true, now(), now()),
    (v_other_user_id, 'phase3f-other@example.test', 'Other', 'adult', true, now(), now())
  on conflict (id) do update set age_band = excluded.age_band, onboarding_completed = true, updated_at = now();

  insert into public.body_double_moderators(user_id)
  values (v_moderator_id)
  on conflict (user_id) do nothing;

  insert into public.body_double_sessions (
    user_id, mode, status, session_type, session_length_minutes,
    communication_mode, privacy_level, started_at, created_at, updated_at
  ) values (
    v_reporter_id, 'random', 'active', 'focusSprint', 25,
    'textOnly', 'private', now(), now(), now()
  ) returning id into v_session_id;

  insert into public.body_double_participants(session_id, user_id, role, status, joined_at)
  values
    (v_session_id, v_reporter_id, 'random', 'active', now()),
    (v_session_id, v_reported_id, 'random', 'active', now());

  insert into public.user_reports(reporter_id, reported_id, session_id, reason, details)
  values (v_reporter_id, v_reported_id, v_session_id, 'Safety concern', 'Admin console fixture')
  returning id into v_report_id;

  insert into public.body_double_message_moderation_events(
    session_id, sender_id, report_id, action, reason, body_preview, created_at
  ) values (
    v_session_id, v_reported_id, v_report_id, 'reported', 'fixture', 'Moderation preview only', now()
  );

  perform set_config('role', 'authenticated', true);

  perform set_config('request.jwt.claim.sub', v_moderator_id::text, true);
  select count(*) into v_can_read from public.user_reports where id = v_report_id;
  if v_can_read <> 1 then raise exception 'Moderator should read report queue'; end if;

  select count(*) into v_can_read from public.body_double_message_moderation_events where report_id = v_report_id;
  if v_can_read <> 1 then raise exception 'Moderator should read moderation events'; end if;

  select count(*) into v_can_read from public.body_double_audit_events;
  if v_can_read < 0 then raise exception 'Moderator audit read check failed'; end if;

  perform public.review_body_double_report(v_report_id, 'reviewed');
  if not exists (select 1 from public.user_reports where id = v_report_id and status = 'reviewed') then
    raise exception 'Moderator review RPC did not update report status';
  end if;

  v_restriction_id := public.restrict_body_double_user(
    v_reported_id,
    'random_suspended',
    'Admin console test restriction',
    now() + interval '7 days',
    v_report_id
  );
  if not exists (select 1 from public.body_double_user_restrictions where id = v_restriction_id and status = 'active') then
    raise exception 'Moderator restriction RPC did not create active restriction';
  end if;

  perform public.revoke_body_double_user_restriction(v_restriction_id, 'Admin console test revoke');
  if not exists (select 1 from public.body_double_user_restrictions where id = v_restriction_id and status = 'revoked') then
    raise exception 'Moderator revoke RPC did not revoke restriction';
  end if;

  perform set_config('request.jwt.claim.sub', v_other_user_id::text, true);
  select count(*) into v_can_read from public.user_reports where id = v_report_id;
  if v_can_read <> 0 then raise exception 'Non-moderator read another user report'; end if;

  select count(*) into v_can_read from public.body_double_message_moderation_events where report_id = v_report_id;
  if v_can_read <> 0 then raise exception 'Non-moderator read moderation events'; end if;

  begin
    perform public.review_body_double_report(v_report_id, 'dismissed');
    raise exception 'Non-moderator reviewed report unexpectedly';
  exception when others then
    if position('moderators' in lower(sqlerrm)) = 0 then raise; end if;
  end;

  begin
    perform public.restrict_body_double_user(v_reported_id, 'random_suspended', 'should fail', null, v_report_id);
    raise exception 'Non-moderator restricted user unexpectedly';
  exception when others then
    if position('moderators' in lower(sqlerrm)) = 0 then raise; end if;
  end;

  begin
    perform public.revoke_body_double_user_restriction(v_restriction_id, 'should fail');
    raise exception 'Non-moderator revoked restriction unexpectedly';
  exception when others then
    if position('moderators' in lower(sqlerrm)) = 0 then raise; end if;
  end;
end $$;

rollback;