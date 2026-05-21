# Dope-i-Mine Phase 3 SQL Drop-in V3

This drop-in adds a late migration that force-replaces:

`public.report_random_body_double_session(...)`

The current SQL verification failure is:

`Expected reported moderation event linked to user report`

Cause: the active report RPC is not reliably creating the linked
`body_double_message_moderation_events` row expected by the Phase 3D/3E SQL harness.

## Files

- `supabase/migrations/202605200004_report_random_body_double_moderation_link.sql`

## Apply

Extract this ZIP over the repo root, then run:

```powershell
npx supabase db reset
psql "$env:SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f supabase/sql/body_double_phase3_rls_rpc_tests.sql
```

## Expected

- `npx supabase db reset` should pass.
- The report test should now find:
  - `user_reports.id = linked_report_id`
  - `body_double_message_moderation_events.report_id = linked_report_id`
  - `body_double_message_moderation_events.sender_id = reported_user_id`
  - `body_double_message_moderation_events.action = 'reported'`
