# Avatar V3 Pass 2C — Ringlet Afro Hair Position

This pass addresses the screenshot where the copper hair still reads like a beard.

## Fix

- Replaces the starter ringlet-afro inline SVG.
- Back hair is now split into:
  - rear halo
  - left side volume
  - right side volume
  - top crown volume
- The centre face/chin/mouth area is deliberately left clear.
- Front hair is now only a crown/fringe layer above the face.
- No long strokes drop over cheeks, jaw, mouth, or chin.

## Run

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\apply_avatar_v3_pass2c_hair_position.ps1
flutter analyze
flutter test
flutter run
```
