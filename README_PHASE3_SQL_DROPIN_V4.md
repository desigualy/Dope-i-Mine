# Dope-i-Mine Phase 3 SQL Drop-in V4

This patch adds a late migration that force-replaces:

`public.report_random_body_double_session(uuid, uuid, text, text)`

The RPC now:

- Drops the previous exact signature first.
- Creates `user_reports`.
- Creates a linked `body_double_message_moderation_events` row with:
  - `action = 'reported'`
  - `sender_id = reported user`
  - `report_id = created report id`
- Self-checks that the linked moderation event exists before returning.
- Blocks the reported participant for the reporter.
- Closes the random session as reported.
- Writes an audit event.

Apply by extracting over the repo root, then run:

```powershell
npx supabase db reset
psql "$env:SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f supabase/sql/body_double_phase3_rls_rpc_tests.sql
```
