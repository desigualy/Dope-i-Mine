# Avatar Engine V4 — Pass 3J Rive Asset Workflow

Pass 3J adds the practical acquisition/build/import workflow for the production Rive rig.

## Added

```text
docs/avatar_v4/AVATAR_V4_BASE_RIVE_BUILD_WORKFLOW.md
docs/avatar_v4/AVATAR_V4_RIVE_ARTIST_DELIVERY_CHECKLIST.md
docs/avatar_v4/AVATAR_V4_RIVE_IMPORT_QA_RUNBOOK.md
assets/avatar_rive/base_avatar_import_manifest.json
tools/import_avatar_v4_base_rive.ps1
tools/verify_avatar_v4_base_rive.ps1
test/avatar_v4/avatar_v4_base_rive_workflow_test.dart
```

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\apply_avatar_v4_pass3j_rive_asset_workflow.ps1
flutter analyze
flutter test
```

## When the real Rive file exists

```powershell
.\tools\import_avatar_v4_base_rive.ps1 -SourcePath "C:\path\to\base_avatar.riv"
.\tools\verify_avatar_v4_base_rive.ps1
flutter analyze
flutter test
flutter run
```
