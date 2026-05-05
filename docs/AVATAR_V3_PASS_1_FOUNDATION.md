# Avatar V3 Pass 1 — Fresh Foundation

This pass replaces the old visible avatar rendering path with Avatar V3.

## Locked rules

- Old renderer is not a fallback.
- Visible avatar path uses Avatar V3 only.
- Avatar creation/rendering is API-free.
- Avatar V3 is local asset-layer based.
- Supabase is for account sync, inventory, entitlements, purchase restore, and cross-device persistence.
- Existing installed/owned items can be used offline.
- Buying/unlocking/restoring/downloading missing assets requires online access.

## New architecture

Avatar profile -> validation/options -> layer resolver -> local SVG/vector assets -> AvatarV3Renderer.

## Added

- Avatar V3 profile model.
- Avatar V3 options and validation.
- Avatar V3 local asset manifest.
- Avatar V3 layer stack renderer.
- Local-first profile/inventory/asset pack/pending sync stores.
- Offline-first repository.
- Supabase repository.
- Supabase SQL tables.
- Starter local SVG asset pack.
- Wrappers replacing old visible renderer classes with Avatar V3 bridge.

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\apply_avatar_v3_pass1_foundation.ps1
flutter pub get
flutter analyze
flutter test
```
