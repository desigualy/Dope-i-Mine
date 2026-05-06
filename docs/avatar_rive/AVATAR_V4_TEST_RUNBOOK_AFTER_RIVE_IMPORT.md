# Avatar V4 Test Runbook After `base_avatar.riv` Is Added

Use this after the real Rive file is placed here:

```text
assets/avatar_rive/base_avatar.riv
```

## Step 1 — Verify file location

```powershell
Test-Path .\assets\avatar_rive\base_avatar.riv
```

Expected:

```text
True
```

## Step 2 — Flutter asset refresh

```powershell
flutter clean
flutter pub get
```

## Step 3 — Static checks

```powershell
flutter analyze
```

Expected:

```text
No issues found
```

## Step 4 — Test suite

```powershell
flutter test
```

Expected:

```text
All tests passed
```

## Step 5 — Run the app

```powershell
flutter run
```

Choose your target:

```text
Windows
Chrome
Edge
Android emulator/device
```

## Step 6 — Check avatar screen

Open:

```text
/avatar/customize
```

Expected:

```text
The missing-rig diagnostic should disappear.
The Rive avatar should render.
The app should not crash.
```

## Step 7 — Contract diagnostic check

If the diagnostic still appears, inspect the message.

Common causes:

```text
Missing Rive artboard: Avatar
Missing Rive state machine: AvatarState
Missing required Rive number input: skinTone
Missing required Rive number input: faceShape
Missing required Rive number input: hairPack
Missing required Rive number input: hairStyle
Missing required Rive number input: hairColor
Missing required Rive number input: bodyPreset
Missing required Rive boolean input: freckles
Missing required Rive boolean input: vitiligo
Missing required Rive boolean input: hasFacialHair
Missing required Rive boolean input: hasGlasses
```

## Step 8 — Visual QA

Use:

```text
docs/avatar_rive/AVATAR_V4_STYLE_ACCEPTANCE_CHECKLIST.md
```

Check:

```text
hair placement
facial hair placement
skin details
body presets
glasses/accessibility items
lighting/shading quality
```

## Step 9 — Reference upload test

Only after Supabase Storage SQL has been applied:

```text
supabase/migrations/202605060002_avatar_reference_storage.sql
```

Test:

```text
1. Sign in.
2. Open avatar customizer.
3. Confirm online.
4. Tick consent.
5. Upload a reference photo.
6. Confirm upload success.
7. Check Supabase Storage bucket:
   avatar-reference-images
8. Check table:
   avatar_uploads
```

Expected:

```text
Storage object exists.
avatar_uploads row exists.
Only consented metadata/path is stored.
```

## Step 10 — Final QA screenshots

Capture:

```text
default avatar
light skin / dark skin variants
straight hair / coily hair / locs / braids
facial hair off/on
freckles off/on
vitiligo off/on
glasses off/on
different body presets
```

Compare against Apple/Meta target references.
