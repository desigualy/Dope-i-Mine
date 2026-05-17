\set ON_ERROR_STOP on

select set_config('request.jwt.claim.sub', '', false);

delete from public.caregiver_email_invites
where id = '00000000-0000-0000-0000-00000000e201';
delete from public.caregiver_relationships
where caregiver_user_id = '00000000-0000-0000-0000-00000000c201'
  and supported_user_id = '00000000-0000-0000-0000-00000000a201';
delete from public.caregiver_profiles
where user_id = '00000000-0000-0000-0000-00000000c201';
delete from public.users_profile
where id in (
  '00000000-0000-0000-0000-00000000a201',
  '00000000-0000-0000-0000-00000000c201'
);
delete from auth.users
where id in (
  '00000000-0000-0000-0000-00000000a201',
  '00000000-0000-0000-0000-00000000c201'
);

insert into auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at
) values
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-00000000a201',
    'authenticated',
    'authenticated',
    'supported.e2e@example.com',
    crypt('password123', gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"display_name":"Supported E2E"}'::jsonb,
    now(),
    now()
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-00000000c201',
    'authenticated',
    'authenticated',
    'caregiver.e2e@example.com',
    crypt('password123', gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"display_name":"Caregiver E2E"}'::jsonb,
    now(),
    now()
  );

insert into public.users_profile (id, email, display_name, account_type)
values
  ('00000000-0000-0000-0000-00000000a201', 'supported.e2e@example.com', 'Supported E2E', 'user'),
  ('00000000-0000-0000-0000-00000000c201', 'caregiver.e2e@example.com', 'Caregiver E2E', 'user')
on conflict (id) do update set
  email = excluded.email,
  display_name = excluded.display_name,
  account_type = excluded.account_type,
  updated_at = now();

insert into public.caregiver_email_invites (
  id,
  inviter_user_id,
  invitee_email,
  role,
  status,
  accepted_user_id,
  accepted_at,
  requires_password_setup,
  password_setup_sent_at,
  expires_at
) values (
  '00000000-0000-0000-0000-00000000e201',
  '00000000-0000-0000-0000-00000000a201',
  'caregiver.e2e@example.com',
  'caregiver',
  'pending',
  null,
  null,
  true,
  null,
  now() + interval '30 days'
);

select set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-00000000c201', false);
select public.accept_caregiver_email_invite('00000000-0000-0000-0000-00000000e201'::uuid) as relationship_json;

select
  i.status as invite_status,
  i.accepted_user_id,
  i.requires_password_setup,
  i.password_setup_sent_at,
  r.status as relationship_status,
  r.caregiver_user_id,
  r.supported_user_id,
  p.account_type as caregiver_account_type
from public.caregiver_email_invites i
join public.caregiver_relationships r
  on r.caregiver_user_id = '00000000-0000-0000-0000-00000000c201'
 and r.supported_user_id = '00000000-0000-0000-0000-00000000a201'
join public.users_profile p
  on p.id = '00000000-0000-0000-0000-00000000c201'
where i.id = '00000000-0000-0000-0000-00000000e201';