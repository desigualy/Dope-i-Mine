# Manual QA Protocol

Run this protocol before beta when automated gates pass. Each linked checklist uses the same fields: Check, Expected result, Pass/Fail, Notes.

| Check | Expected result | Pass/Fail | Notes |
| --- | --- | --- | --- |
| Run `flutter pub get` | Dependencies resolve without errors. |  |  |
| Run `flutter analyze` | No analyzer errors. |  |  |
| Run `flutter test` | All automated tests pass. |  |  |
| Run `tools/qa/test_fast_gate.ps1` | Fast QA gate passes without breaking existing scripts. |  |  |
| Complete Device QA | `BETA_DEVICE_QA_CHECKLIST.md` has no blocking failures. |  |  |
| Complete Role Routing QA | `ROLE_ROUTING_QA_CHECKLIST.md` has no blocking failures. |  |  |
| Complete Caregiver QA | `CAREGIVER_QA_CHECKLIST.md` has no blocking failures. |  |  |
| Complete Voice and Notification QA | `VOICE_NOTIFICATION_QA_CHECKLIST.md` has no blocking failures. |  |  |
| Complete Body Double QA | `BODY_DOUBLE_QA_CHECKLIST.md` has no blocking failures. |  |  |
| Complete Offline Sync QA | `OFFLINE_SYNC_QA_CHECKLIST.md` has no blocking failures. |  |  |
| Complete Accessibility and Avatar QA | `ACCESSIBILITY_AVATAR_QA_CHECKLIST.md` has no blocking failures. |  |  |
| Complete Supabase Deployment QA | `SUPABASE_DEPLOYMENT_QA_CHECKLIST.md` has no blocking failures before staging or production deploy. |  |  |
| Confirm automated/manual split | `PHASE_3L_AUTOMATED_QA_PROTOCOLS.md` and `MANUAL_TO_AUTOMATED_QA_MATRIX.md` identify what remains manual before beta. |  |  |

