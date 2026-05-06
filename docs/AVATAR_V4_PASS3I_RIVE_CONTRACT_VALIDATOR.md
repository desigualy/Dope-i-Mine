# Avatar Engine V4 — Pass 3I Rive Contract Validator

Pass 3I adds runtime diagnostics for the real `.riv` file.

## What it detects

```text
missing base_avatar.riv
unreadable/invalid Rive file
missing Avatar artboard
missing AvatarState state machine
missing required number inputs
missing required boolean inputs
```

## Required `.riv` contract

```text
assets/avatar_rive/base_avatar.riv
Artboard: Avatar
State machine: AvatarState
```

## Required inputs

```text
skinTone
faceShape
hairPack
hairStyle
hairColor
bodyPreset
freckles
vitiligo
hasFacialHair
hasGlasses
```

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\apply_avatar_v4_pass3i_rive_contract_validator.ps1
flutter analyze
flutter test
```
