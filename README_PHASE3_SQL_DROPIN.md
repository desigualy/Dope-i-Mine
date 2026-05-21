# Dope-i-Mine Phase 3 SQL Drop-in Fix

Extract this ZIP over the repo root.

It replaces:

- `supabase/migrations/202605080002_body_double_phase2_friend.sql`
- `supabase/sql/body_double_phase3_rls_rpc_tests.sql`

It adds:

- `supabase/migrations/202605200002_body_double_known_person_invite_rls.sql`

Then run:

```powershell
npx supabase db reset
psql "$env:SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f supabase/sql/body_double_phase3_rls_rpc_tests.sql
```
