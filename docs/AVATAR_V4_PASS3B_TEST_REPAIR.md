# Avatar V4 Pass 3B Test Repair

This repair updates old tests that still expected the removed V3/home avatar surface.

## Fixes

- Replaces `home-unified-user-avatar` expectations with `home-avatar-v4-rive`.
- Updates the Home avatar test to scroll before asserting lower menu actions.
- Adds `/avatar/customize` to the onboarding test router.
- Replaces the obsolete "settings avatar editor saves profile changes back to home" test with a V4 customizer routing test.

## Run

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\repair_avatar_v4_pass3b_tests.ps1
flutter analyze
flutter test
```
