# Avatar V3 Pass 2D — Procedural Ringlet Afro

This pass stops using the single SVG blob for the ringlet-afro hair.

## New structure

```text
lib/presentation/avatar_v3/hair/ringlet_afro/
  ringlet_hair_geometry.dart
  ringlet_curl_painter.dart
  ringlet_afro_hair.dart
```

## What changed

- Back hair is now a procedural `CustomPaint` layer.
- Front hair is now a separate procedural `CustomPaint` layer.
- Hair is made from many curl units, not one closed blob.
- Geometry explicitly defines:
  - rear halo
  - left side volume
  - right side volume
  - crown volume
  - temple curls
- Mouth/chin exclusion is encoded as testable geometry.
- `AvatarV3LayerStack` routes ringlet-afro hair layer IDs to procedural widgets.

## Run

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\apply_avatar_v3_pass2d_procedural_ringlet_afro.ps1
flutter analyze
flutter test
flutter run
```

## Visual target

This is still not the final Apple/Meta art pass. It is the correct rendering architecture for this hair type, so the avatar can now improve through geometry and paint rather than blob SVG edits.
