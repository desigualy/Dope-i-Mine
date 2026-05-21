# Phase 3 SQL Drop-in V2

This drop-in fixes the SQL verification failure:

`Expected blocked link moderation event`

PostgreSQL rolls back writes inside a function when that same function raises an exception. The previous RPC inserted a blocked moderation event and then raised, so the event was rolled back.

This adds:

- `supabase/migrations/202605200003_random_text_moderation_events_persist.sql`
- patched `supabase/sql/body_double_phase3_rls_rpc_tests.sql`

After extracting over the repo root, run:

```powershell
npx supabase db reset
psql "$env:SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f supabase/sql/body_double_phase3_rls_rpc_tests.sql
```
