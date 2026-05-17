const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const { execFileSync } = require('node:child_process');

const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';
const jwtSecret = 'super-secret-jwt-token-with-at-least-32-characters-long';
const functionsUrl = 'http://127.0.0.1:54321/functions/v1';

const supportedId = '00000000-0000-0000-0000-00000000a301';
const caregiverId = '00000000-0000-0000-0000-00000000c301';
const inviteId = '00000000-0000-0000-0000-00000000e301';

function b64url(value) {
    return Buffer.from(JSON.stringify(value)).toString('base64url');
}

function signJwt(payload) {
    const header = b64url({ alg: 'HS256', typ: 'JWT' });
    const body = b64url(payload);
    const signature = crypto
        .createHmac('sha256', jwtSecret)
        .update(`${header}.${body}`)
        .digest('base64url');
    return `${header}.${body}.${signature}`;
}

function runPsql(sql) {
    return execFileSync(
        'docker',
        ['exec', '-i', 'supabase_db_dope_i_mine_pass_12_analyze_fix', 'psql', '-U', 'postgres', '-d', 'postgres', '-v', 'ON_ERROR_STOP=1'],
        { input: sql, encoding: 'utf8' },
    );
}

function setupInvite() {
    runPsql(`
delete from public.caregiver_email_invites where id = '${inviteId}';
delete from public.caregiver_relationships where caregiver_user_id = '${caregiverId}' and supported_user_id = '${supportedId}';
delete from public.caregiver_profiles where user_id = '${caregiverId}';
delete from public.users_profile where id in ('${supportedId}', '${caregiverId}');
delete from auth.users where id in ('${supportedId}', '${caregiverId}');

insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, confirmation_token, recovery_token, email_change_token_new, email_change, email_change_token_current, reauthentication_token, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
values
('00000000-0000-0000-0000-000000000000', '${supportedId}', 'authenticated', 'authenticated', 'supported.edge@example.com', crypt('password123', gen_salt('bf')), now(), '', '', '', '', '', '', '{"provider":"email","providers":["email"]}'::jsonb, '{"display_name":"Supported Edge"}'::jsonb, now(), now()),
('00000000-0000-0000-0000-000000000000', '${caregiverId}', 'authenticated', 'authenticated', 'caregiver.edge@example.com', crypt('password123', gen_salt('bf')), now(), '', '', '', '', '', '', '{"provider":"email","providers":["email"]}'::jsonb, '{"display_name":"Caregiver Edge"}'::jsonb, now(), now());

insert into public.users_profile (id, email, display_name, account_type)
values
('${supportedId}', 'supported.edge@example.com', 'Supported Edge', 'user'),
('${caregiverId}', 'caregiver.edge@example.com', 'Caregiver Edge', 'user')
on conflict (id) do update set email = excluded.email, display_name = excluded.display_name, account_type = excluded.account_type, updated_at = now();

insert into public.caregiver_email_invites (id, inviter_user_id, invitee_email, role, status, accepted_user_id, accepted_at, requires_password_setup, password_setup_sent_at, expires_at)
values ('${inviteId}', '${supportedId}', 'caregiver.edge@example.com', 'caregiver', 'pending', null, null, false, null, now() + interval '30 days');
`);
}

function readResult() {
    return runPsql(`
select jsonb_pretty(jsonb_build_object(
  'invite', (select to_jsonb(i) from public.caregiver_email_invites i where i.id = '${inviteId}'),
  'relationship', (select to_jsonb(r) from public.caregiver_relationships r where r.caregiver_user_id = '${caregiverId}' and r.supported_user_id = '${supportedId}'),
  'caregiverProfile', (select to_jsonb(p) from public.users_profile p where p.id = '${caregiverId}')
));
`);
}

async function main() {
    setupInvite();

    const token = signJwt({
        aud: 'authenticated',
        role: 'authenticated',
        email: 'caregiver.edge@example.com',
        sub: caregiverId,
        exp: Math.floor(Date.now() / 1000) + 60 * 60,
    });

    const response = await fetch(`${functionsUrl}/accept-caregiver-invite`, {
        method: 'POST',
        headers: {
            apikey: anonKey,
            authorization: `Bearer ${token}`,
            'content-type': 'application/json',
        },
        body: JSON.stringify({ inviteId }),
    });

    const bodyText = await response.text();
    let body;
    try {
        body = JSON.parse(bodyText);
    } catch (_) {
        body = bodyText;
    }

    assert.equal(response.status, 200, bodyText);
    assert.equal(body.ok, true);
    assert.equal(body.relationship.caregiver_user_id, caregiverId);
    assert.equal(body.relationship.supported_user_id, supportedId);
    assert.equal(body.passwordSetup.required, false);
    assert.equal(body.passwordSetup.alreadySent, false);
    assert.equal(body.passwordSetup.sent, false);

    const resultText = readResult();
    assert.match(resultText, /"status": "accepted"/);
    assert.match(resultText, new RegExp(`"accepted_user_id": "${caregiverId}"`));
    assert.match(resultText, /"relationship"/);
    assert.match(resultText, /"account_type": "caregiver"/);

    console.log('PASS real Supabase Edge Function caregiver invite E2E');
    console.log(JSON.stringify({ httpStatus: response.status, response: body }, null, 2));
    console.log(resultText);
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});