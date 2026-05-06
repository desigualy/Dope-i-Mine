# Avatar V3 Pass 2B — Profile Resolution

This pass fixes the bald/simple home avatar after the V3 visibility patch.

## Why this was needed

The new V3 renderer was active and visible, but Home was feeding it an old default/incomplete profile. That old profile resolved to a non-supported or simple hair state, so the V3 resolver produced a bald/simple avatar.

## Rules

- If the old legacy default profile is detected, promote it to the V3 starter profile.
- V3 starter profile uses:
  - tan warm skin
  - ringletAfro
  - longRingletAfro
  - copper hair
  - freckles
- While Pass 2B only has one finished starter hair asset family, every non-bald/non-shaved hair profile gets starter visible hair rather than rendering bald.
- Deliberate V3 bald/shaved remains bald/shaved.

## Run

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\apply_avatar_v3_pass2b_profile_resolution.ps1
flutter analyze
flutter test
flutter run
```
