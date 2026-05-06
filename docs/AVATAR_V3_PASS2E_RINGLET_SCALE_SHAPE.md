# Avatar V3 Pass 2E — Ringlet Scale and Shape

This fixes the oversized hoop/ring hair produced by Pass 2D.

## Problem

Pass 2D used true separate curl geometry, but the curl radius/stroke values were far too large, so the result looked like orange hoop jewellery around the face.

## Fix

- Shrinks curl radius and stroke width.
- Adds soft filled hair masses behind the curl texture:
  - rear halo
  - left side mass
  - right side mass
  - crown mass
- Keeps curls as texture, not the whole shape.
- Keeps mouth/chin clear.
- Adds tests for small natural curl scale.

## Run

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\apply_avatar_v3_pass2e_ringlet_scale_shape.ps1
flutter analyze
flutter test
flutter run
```
