# Dope-i-Mine Phase 3 SQL Drop-in V5

This is a SQL verification harness patch only.

`npx supabase db reset` is already passing. The remaining failure happens because:

- `report_random_body_double_session(...)` correctly creates the linked `body_double_message_moderation_events` row.
- The test then tries to read that moderation row while still using `adult_b` as `auth.uid()`.
- `adult_b` is not a moderator.
- RLS correctly hides `body_double_message_moderation_events` from non-moderators.

This patch changes the test harness to switch to `adult_a`, which is seeded as the local body-double moderator, before checking the reported moderation event.

## Apply

From the repo root:

```powershell
.\tools\patch_phase3_sql_test_moderator_context.ps1
```

Then run:

```powershell
npx supabase db reset
psql "$env:SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f supabase/sql/body_double_phase3_rls_rpc_tests.sql
```

Alternative:

```powershell
git apply .\PATCH_phase3_sql_test_moderator_context.patch
```
