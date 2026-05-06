# Avatar V3 Pass 2A — Visibility Hard-Fix

Fixes the blank-avatar issue.

## Changes

- `AvatarV3Renderer` always has a default non-null profile.
- `AvatarV3Renderer` always enforces visible square constraints.
- `AvatarEngineBridge` handles null profile safely.
- `AvatarV3LayerStack` uses bundled inline SVG asset strings for the starter avatar, so asset path/bundle problems cannot produce a blank avatar.
- Adds visibility tests.

## Run

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\apply_avatar_v3_pass2a_visibility.ps1
flutter analyze
flutter test
flutter run
```
