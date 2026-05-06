# Avatar Engine V4 — Pass 3I Rive Handoff Pack

Pass 3I creates the handoff pack for producing the real `base_avatar.riv`.

## Added

```text
docs/avatar_v4/AVATAR_V4_RIVE_HANDOFF_SPEC.md
docs/avatar_v4/AVATAR_V4_RIVE_INPUT_MAP.md
docs/avatar_v4/AVATAR_V4_LAYER_NAMING_CONTRACT.md
docs/avatar_v4/AVATAR_V4_QA_CHECKLIST.md
docs/avatar_v4/AVATAR_V4_ARTIST_BRIEF.md
assets/avatar_rive/base_avatar.riv.README_PLACEHOLDER.txt
assets/avatar_rive/avatar_v4_rive_handoff.json
test/avatar_v4/avatar_v4_rive_handoff_pack_test.dart
```

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\apply_avatar_v4_pass3i_rive_handoff_pack.ps1
flutter analyze
flutter test
```

## Production asset required next

```text
assets/avatar_rive/base_avatar.riv
```
