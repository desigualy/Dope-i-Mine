# Avatar Engine V4 — base_avatar.riv Build Workflow

## Goal

Produce and import the real production avatar rig:

```text
assets/avatar_rive/base_avatar.riv
```

This is the file that replaces the retired V2/V3 blob avatar renderer.

## Build route options

### Route A — Rive artist workflow

Use this when working with a Rive designer/animator.

```text
1. Send docs/avatar_v4/AVATAR_V4_ARTIST_BRIEF.md
2. Send docs/avatar_v4/AVATAR_V4_RIVE_HANDOFF_SPEC.md
3. Send docs/avatar_v4/AVATAR_V4_RIVE_INPUT_MAP.md
4. Send docs/avatar_v4/AVATAR_V4_LAYER_NAMING_CONTRACT.md
5. Request base_avatar.riv and preview PNGs
6. Import .riv with tools/import_avatar_v4_base_rive.ps1
7. Run tools/verify_avatar_v4_base_rive.ps1
8. Run flutter analyze
9. Run flutter test
10. Run the app and inspect Home + Avatar customizer
```

### Route B — internal prototype workflow

Use this when building the first rig yourself.

```text
1. Open Rive
2. Create artboard named Avatar
3. Create state machine named AvatarState
4. Add required number inputs
5. Add required boolean inputs
6. Build only the starter avatar first
7. Export as base_avatar.riv
8. Import into assets/avatar_rive/base_avatar.riv
9. Verify in Flutter
10. Add more hair/body/accessory variants only after the starter rig loads
```

### Route C — temporary diagnostic-only route

Use this only while waiting for real art.

```text
Keep missing-rig diagnostic visible.
Do not re-enable old V3 blob renderer.
Do not ship fake SVG as if it is the premium avatar.
```

## Required Rive identity

```text
File: assets/avatar_rive/base_avatar.riv
Artboard: Avatar
State machine: AvatarState
```

## Required state machine inputs

Number inputs:

```text
skinTone
faceShape
hairPack
hairStyle
hairColor
bodyPreset
```

Boolean inputs:

```text
freckles
vitiligo
hasFacialHair
hasGlasses
```

## Import command

After receiving or exporting the `.riv` file:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\import_avatar_v4_base_rive.ps1 -SourcePath "C:\path\to\base_avatar.riv"
```

Then verify:

```powershell
.\tools\verify_avatar_v4_base_rive.ps1
flutter analyze
flutter test
flutter run
```

## Expected app behaviour after successful import

```text
Home: no old V3 blob avatar
Home: AvatarRiveView renders actual rig
Customizer: AvatarRiveView renders actual rig
Missing-rig diagnostic: no longer shown when base_avatar.riv exists and loads
Reference image panel: still visible
Offline upload guard: still active
```

## Failure rules

If the imported `.riv` does not work:

```text
Do not re-enable V3.
Do not patch with fake blobs.
Do not rename runtime inputs to match a bad rig.
Fix the Rive rig to match the locked contract.
```
