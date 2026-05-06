# Avatar V4 Pass 3A Diagnostic Overflow Repair

Fixes the failing widget test caused by the missing-rig diagnostic overflowing at 180x180.

## Problem

`AvatarMissingRigDiagnostic` used a fixed `Column` with icon, title, spacing, and asset path. At 180px the available padded space was only 140px high, causing:

```text
A RenderFlex overflowed by 28 pixels on the bottom.
```

## Fix

- Uses `FittedBox(scaleDown)` so diagnostic content cannot overflow.
- Uses compact mode under 210px.
- Hides the asset path in compact mode.
- Keeps the test-visible text `Avatar rig missing`.

Run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\repair_avatar_v4_pass3a_diagnostic_overflow.ps1
flutter analyze
flutter test
```
