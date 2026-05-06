# Avatar V4 Pass 3M — Restore Flow Tests + Add Route Contract

The previous repair inserted `Sex, gender & pronouns` expectations inside broad wizard flow tests. Those tests are brittle and do not reliably expose the new route in the expected place.

This repair does the clean version:

```text
1. Removes misplaced identity expectation blocks from onboarding_flow_test.dart.
2. Keeps the actual app route fix:
   voice setup -> /onboarding/identity
3. Keeps router route:
   /onboarding/identity
4. Adds source-contract tests to avatar_v4_onboarding_purge_test.dart proving:
   - voice_setup_screen.dart routes to /onboarding/identity
   - router.dart exposes /onboarding/identity
```

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\repair_avatar_v4_pass3m_restore_flow_tests_add_route_contract.ps1
flutter analyze
flutter test
```
