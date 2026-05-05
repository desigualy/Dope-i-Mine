# Avatar V2 Pass 2 — Live App Wiring

Pass 2 wires Avatar V2 into the live app flow without deleting the legacy avatar system.

## What changes

- Home now shows `AvatarV2HomeHero` in the existing avatar position.
- Settings/Companion screen gets an `AvatarV2SettingsPanel`.
- Onboarding avatar step gets an `AvatarV2OnboardingPanel`.
- Avatar V2 profile persists locally through `LocalAvatarV2Store`.
- Avatar V2 can migrate from the existing `AvatarConfigModel`.
- Legacy avatar remains present as fallback/compatibility.

## Apply

From the project root:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\apply_avatar_v2_pass2_wire.ps1
flutter analyze
flutter test
```

## New files

- `lib/data/local/local_avatar_v2_store.dart`
- `lib/domain/avatar_v2/avatar_v2_legacy_bridge.dart`
- `lib/presentation/avatar_v2/current_avatar_v2_provider.dart`
- `lib/presentation/avatar_v2/avatar_v2_live_widgets.dart`
- `test/avatar_v2/avatar_v2_legacy_bridge_test.dart`

## Deliberate constraint

This pass does not delete or retire old avatar files. That happens only after Avatar V2 is visually accepted.
