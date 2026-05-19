-- Phase 3 body-double schema/RLS contract checks.
-- Run against a disposable or staging database after migrations are applied.

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
  exists (
    select 1
    from information_schema.tables
    where table_schema = 'public'
      and table_name like 'body_double%'
  ),
  'Expected at least one public body_double* table for Phase 3 body-double runtime'
);

select public.__phase3_assert(
  exists (
    select 1
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname like 'body_double%'
      and c.relrowsecurity = true
  ),
  'At least one body_double* table must have RLS enabled'
);

rollback;
