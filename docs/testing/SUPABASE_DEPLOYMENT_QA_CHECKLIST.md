# Supabase Deployment QA Checklist

| Check | Expected result | Pass/Fail | Notes |
| --- | --- | --- | --- |
| Run `npx supabase db reset` | Local reset passes. |  |  |
| Run existing SQL/RLS tests | Existing SQL/RLS tests pass. |  |  |
| Run body-double SQL test | `body_double_phase3_rls_rpc_tests.sql` passes. |  |  |
| Run notification runtime SQL test | `notification_runtime_rls_tests.sql` passes if present. |  |  |
| Run sync runtime SQL test | `sync_runtime_rls_tests.sql` passes if present. |  |  |
| Run accessibility SQL test | `accessibility_preferences_rls_tests.sql` passes if present. |  |  |
| Run onboarding/setup SQL tests if added | User can read/insert/update own setup preferences only. |  |  |
| Run `npx supabase db push` on staging | Staging push passes before production. |  |  |
| Deploy required Edge Functions individually | Each required function deploys successfully. |  |  |
| Check `generate-avatar-candidates` secrets | Required secrets exist before deployment. |  |  |
| Check `send-caregiver-invite` | Function works with current invite flow. |  |  |
| Check `send-caregiver-password-setup` dependency | App does not falsely rely on it when temporary-password flow is canonical. |  |  |
| Check schema cache issue paths | Previously affected routes do not fail from stale schema cache. |  |  |
| Confirm no secrets committed | No API keys or secrets are committed. |  |  |

