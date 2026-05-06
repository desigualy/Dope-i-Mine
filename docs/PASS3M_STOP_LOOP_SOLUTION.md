# PASS 3M Stop-Loop Solution

This is not another small regex nudge. It directly replaces the corrupted purge test and fixes the real app files that were damaged by earlier patching.

## Fixes

```text
1. Adds missing IdentityScreen import to onboarding_flow_test.dart.
2. Suppresses the unused helper warning in onboarding_flow_test.dart.
3. Replaces corrupted avatar_v4_onboarding_purge_test.dart completely.
4. Fixes onboarding_summary_screen.dart to use:
   state.sexAtBirth.label
   state.genderIdentity.label
   state.pronounDisplay
5. Re-locks voice setup to /onboarding/identity.
6. Ensures router still exposes /onboarding/identity.
```

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\apply_pass3m_stop_loop_solution.ps1
flutter analyze
flutter test
```
