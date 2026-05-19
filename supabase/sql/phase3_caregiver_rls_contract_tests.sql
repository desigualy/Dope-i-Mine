-- Phase 3 caregiver/schema contract checks.
-- Run against a disposable or staging database after migrations are applied.
-- This script intentionally checks schema/RLS contracts only; it does not seed user data.

begin;

create or replace function public.__phase3_assert(condition boolean, message text)
returns void
language plpgsql
as $$
begin
  if not condition then
    raise exception '%', message;
  end if;
end;
$$;

select public.__phase3_assert(
  to_regclass('public.users_profile') is not null,
  'users_profile table is missing'
);

select public.__phase3_assert(
  to_regclass('public.caregiver_email_invites') is not null,
  'caregiver_email_invites table is missing'
);

select public.__phase3_assert(
  to_regclass('public.caregiver_relationships') is not null,
  'caregiver_relationships table is missing'
);

select public.__phase3_assert(
  exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'users_profile'
      and column_name = 'must_change_password'
  ),
  'users_profile.must_change_password is missing'
);

select public.__phase3_assert(
  exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'users_profile'
      and column_name = 'temporary_password_created_at'
  ),
  'users_profile.temporary_password_created_at is missing'
);

select public.__phase3_assert(
  exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'caregiver_email_invites'
      and column_name = 'temporary_password_set_at'
  ),
  'caregiver_email_invites.temporary_password_set_at is missing'
);

select public.__phase3_assert(
  exists (
    select 1
    from pg_indexes
    where schemaname = 'public'
      and indexname = 'users_profile_must_change_password_idx'
  ),
  'users_profile_must_change_password_idx is missing'
);

select public.__phase3_assert(
  exists (
    select 1
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname = 'caregiver_relationships'
      and c.relrowsecurity = true
  ),
  'caregiver_relationships must have RLS enabled'
);

select public.__phase3_assert(
  exists (
    select 1
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname = 'caregiver_email_invites'
      and c.relrowsecurity = true
  ),
  'caregiver_email_invites must have RLS enabled'
);

select public.__phase3_assert(
  exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'caregiver_relationships'
  ),
  'caregiver_relationships should have at least one RLS policy'
);

select public.__phase3_assert(
  exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'caregiver_email_invites'
  ),
  'caregiver_email_invites should have at least one RLS policy'
);

rollback;
