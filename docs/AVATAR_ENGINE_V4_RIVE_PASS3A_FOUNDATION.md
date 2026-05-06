# Avatar Engine V4 — Rive Pass 3A Foundation

This pass stops pretending that `CustomPaint` can produce Apple/Meta-quality avatars.

## What this adds

```text
lib/avatar_engine_v4/
  avatar_engine_v4.dart
  domain/
    avatar_engine_mode.dart
    avatar_v4_config.dart
    avatar_v4_inventory.dart
  data/
    avatar_v4_local_cache.dart
    avatar_v4_repository.dart
  runtime/
    avatar_rive_asset_resolver.dart
    avatar_rive_controller.dart
  presentation/
    avatar_rive_view.dart
    avatar_missing_rig_diagnostic.dart
    avatar_customizer_screen.dart
```

## Rules implemented

- Rive is the primary avatar runtime.
- V3 is no longer the target public renderer.
- If `.riv` art is missing, the UI shows a clear missing-rig diagnostic.
- It does not fake Apple/Meta quality with blob art.
- Local cache exists for selected config and owned items.
- Repository contract exists for Supabase sync.
- User appearance updates are ready to be gated online.
- Owned/unlocked items are ready to be cached locally for offline use.

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\apply_avatar_v4_rive_pass3a_foundation.ps1
flutter pub get
flutter analyze
flutter test
```

## Next required asset

The app now needs:

```text
assets/avatar_rive/base_avatar.riv
```

Expected Rive setup:

```text
Artboard: Avatar
State machine: AvatarState
Inputs:
  skinTone: number
  faceShape: number
  hairPack: number
  hairStyle: number
  hairColor: number
  bodyPreset: number
  freckles: boolean
  vitiligo: boolean
  hasFacialHair: boolean
  hasGlasses: boolean
```
