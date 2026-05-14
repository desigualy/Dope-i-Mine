# Body Double Phase 3C Verification

Phase 3C SQL safety verification is intentionally designed to run only against a disposable/local Supabase Postgres database. The script inserts temporary auth/profile fixtures, exercises RLS/RPC boundaries, then rolls back.

## Local command

```powershell
$env:SUPABASE_DB_URL = 'postgres://postgres:postgres@127.0.0.1:54322/postgres'
./tools/verify_body_double_phase3c_sql.ps1
```

Equivalent direct command:

```bash
psql "$SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f supabase/sql/body_double_phase3_rls_rpc_tests.sql
```

## Prerequisites

- A disposable Supabase/Postgres database with migrations applied through `supabase/migrations/202605090001_body_double_phase3_random.sql`.
- `psql` available on `PATH`.
- Do not point this script at production.

## Coverage

The verification script checks:

- random queue eligibility and minor guardian gating
- no adult/minor random matching
- random text is adult-only and RPC-only
- blocked/allowed moderation events are recorded
- report-to-moderation-event linkage via `report_id`
- rate limiting
- stale random lifecycle cleanup
- block prevents future matching
- moderator report/restriction workflow
- retention cleanup scrubs aged allowed previews

## Current local status

On this machine, direct execution is blocked until a disposable database is available: Supabase CLI is not installed, Docker Desktop service is stopped, and local PostgreSQL service is stopped.