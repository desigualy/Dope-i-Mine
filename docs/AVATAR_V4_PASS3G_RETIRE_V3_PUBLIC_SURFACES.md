# Avatar Engine V4 — Pass 3G Retire V3 Public Surfaces

Pass 3G locks the policy that the old V3/blob/SVG avatar renderer is no longer a public user-facing avatar renderer.

## What this pass does

```text
Adds AvatarV4RetirementPolicy
Adds tests that public avatar surfaces do not import retired V3/fallback files
Adds tests that public avatar surfaces do not reference retired V3/fallback symbols
Confirms Home remains wired to AvatarRiveView / home-avatar-v4-rive
```

## Retired public engines

```text
Avatar V2 CustomPainter
Avatar V3 SVG/blob/layer renderer
UnifiedUserAvatar public fallback
FloatingDopeiAvatar public fallback
```

## Public surfaces protected

```text
lib/presentation/home/home_screen.dart
lib/presentation/user_avatar/user_avatar_studio.dart
lib/avatar_engine_v4/presentation/avatar_customizer_screen.dart
```

## Important

This pass does not delete every old V3 development file yet, because old tests and migration safety still refer to some V3 files. It prevents V3 from being used as the public renderer.

Physical deletion should happen only after a separate repo-wide import scan and test cleanup pass.

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\apply_avatar_v4_pass3g_retire_v3_public_surfaces.ps1
flutter analyze
flutter test
```
