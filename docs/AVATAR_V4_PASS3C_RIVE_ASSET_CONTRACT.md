# Avatar Engine V4 — Pass 3C Rive Asset Contract

Pass 3C locks the local Rive rig contract so the app is ready for a real Apple/Meta-style avatar asset.

## Required file

```text
assets/avatar_rive/base_avatar.riv
```

## Required Rive setup

```text
Artboard: Avatar
State machine: AvatarState
```

## Required number inputs

```text
skinTone
faceShape
hairPack
hairStyle
hairColor
bodyPreset
```

## Required boolean inputs

```text
freckles
vitiligo
hasFacialHair
hasGlasses
```

## Placeholder strategy

Until `base_avatar.riv` exists, the app must show `AvatarMissingRigDiagnostic`.

It must not fall back to the V3 blob/SVG/CustomPaint avatar as the public renderer. That old renderer is not good enough for release quality.

## What this pass adds

```text
lib/avatar_engine_v4/domain/avatar_v4_rive_contract.dart
lib/avatar_engine_v4/domain/avatar_v4_rig_status.dart
assets/avatar_rive/README.md
assets/avatar_rive/avatar_v4_rive_contract.json
test/avatar_v4/avatar_v4_rive_contract_test.dart
```

It also updates:

```text
AvatarV4Config
AvatarRiveController
avatar_engine_v4.dart exports
```

## Run

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\apply_avatar_v4_pass3c_rive_asset_contract.ps1
flutter analyze
flutter test
```
