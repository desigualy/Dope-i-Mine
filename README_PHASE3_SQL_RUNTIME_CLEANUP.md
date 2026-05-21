# Dope-i-Mine Phase 3 SQL Runtime Cleanup

This fixes the root test-harness problem: app-user Phase 3 runtime/RLS verification was mixed with admin-only moderation-retention cleanup verification.

## Apply

Extract over the repo root, then run:

```powershell
.\tools\fix_phase3_runtime_sql_test.cmd
```

Then run:

```powershell
psql "$env:SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f supabase/sql/body_double_phase3_rls_rpc_tests.sql
```

## Optional admin-retention verification

```powershell
psql "$env:SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f supabase/sql/body_double_moderation_retention_admin_tests.sql
```

No `db reset` is required if migrations are already applied.
