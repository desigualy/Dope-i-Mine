 const assert = require('node:assert/strict');
const { execFileSync } = require('node:child_process');

const dbContainer = process.env.SUPABASE_DB_CONTAINER || 'supabase_db_dope_i_mine_pass_12_analyze_fix';
const userId = '00000000-0000-0000-0000-00000000v001';

function runPsql(sql) {
    return execFileSync(
        'docker',
        ['exec', '-i', dbContainer, 'psql', '-U', 'postgres', '-d', 'postgres', '-v', 'ON_ERROR_STOP=1'],
        { input: sql, encoding: 'utf8' },
    );
}

function main() {
    const output = runPsql(`
    insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, confirmation_token, recovery_token, email_change_token_new, email_change, email_change_token_current, reauthentication_token, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
    values ('00000000-0000-0000-0000-000000000000', '${userId}', 'authenticated', 'authenticated', 'voice.e2e@example.com', crypt('password123', gen_salt('bf')), now(), '', '', '', '', '', '', '{"provider":"email","providers":["email"]}'::jsonb, '{"display_name":"Voice E2E"}'::jsonb, now(), now())
    on conflict (id) do update set email = excluded.email, updated_at = now();

    insert into public.users_profile (id, email, display_name, onboarding_completed)
    values ('${userId}', 'voice.e2e@example.com', 'Voice E2E', true)
    on conflict (id) do update set email = excluded.email, onboarding_completed = true, updated_at = now();

    insert into public.user_voice_settings (user_id, active_voice_profile_id, locale_id, speech_rate, auto_read_steps, auto_read_sidequests)
    values ('${userId}', 'uk_female_calm_guide', 'en-GB', 0.42, true, true)
    on conflict (user_id) do update set
      active_voice_profile_id = excluded.active_voice_profile_id,
      locale_id = excluded.locale_id,
      speech_rate = excluded.speech_rate,
      auto_read_steps = excluded.auto_read_steps,
      auto_read_sidequests = excluded.auto_read_sidequests,
      updated_at = now();

    select jsonb_pretty(jsonb_build_object(
      'voiceProfileCount', (select count(*) from public.voice_profiles where is_active),
      'ukFemaleCount', (select count(*) from public.voice_profiles where accent = 'UK' and gender = 'female' and is_active),
      'ukMaleCount', (select count(*) from public.voice_profiles where accent = 'UK' and gender = 'male' and is_active),
      'usFemaleCount', (select count(*) from public.voice_profiles where accent = 'US' and gender = 'female' and is_active),
      'usMaleCount', (select count(*) from public.voice_profiles where accent = 'US' and gender = 'male' and is_active),
      'settings', (select to_jsonb(s) from public.user_voice_settings s where s.user_id = '${userId}'),
      'selectedProfile', (select to_jsonb(p) from public.voice_profiles p where p.id = 'uk_female_calm_guide'),
      'ttsConfigured', exists (select 1 from public.user_voice_settings s join public.voice_profiles p on p.id = s.active_voice_profile_id where s.user_id = '${userId}' and s.locale_id = p.locale_id),
      'sttConfigured', exists (select 1 from public.user_voice_settings s where s.user_id = '${userId}' and s.locale_id in ('en-GB', 'en-US'))
    ));
  `);

    assert.match(output, /"voiceProfileCount": 8/);
    assert.match(output, /"ukFemaleCount": 2/);
    assert.match(output, /"ukMaleCount": 2/);
    assert.match(output, /"usFemaleCount": 2/);
    assert.match(output, /"usMaleCount": 2/);
    assert.match(output, /"active_voice_profile_id": "uk_female_calm_guide"/);
    assert.match(output, /"locale_id": "en-GB"/);
    assert.match(output, /"ttsConfigured": true/);
    assert.match(output, /"sttConfigured": true/);

    console.log('PASS live DB voice profile + TTS/STT configuration E2E');
    console.log(output);
}

main();