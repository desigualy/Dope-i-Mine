# Avatar Engine V4 — Pass 3H Rive Asset Handoff Pack

Pass 3H adds the practical handoff pack for producing the real `base_avatar.riv`.

## Added

```text
docs/avatar_rive/AVATAR_V4_RIVE_ARTIST_BRIEF.md
docs/avatar_rive/AVATAR_V4_RIVE_TECHNICAL_CONTRACT.md
docs/avatar_rive/AVATAR_V4_STYLE_ACCEPTANCE_CHECKLIST.md
assets/avatar_rive/base_avatar.README.md
assets/avatar_rive/base_avatar_contract_checklist.json
lib/avatar_engine_v4/domain/avatar_v4_asset_handoff.dart
test/avatar_v4/avatar_v4_asset_handoff_test.dart
```

## Required final asset

```text
assets/avatar_rive/base_avatar.riv
```

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\apply_avatar_v4_pass3h_rive_asset_handoff.ps1
flutter analyze
flutter test
```
