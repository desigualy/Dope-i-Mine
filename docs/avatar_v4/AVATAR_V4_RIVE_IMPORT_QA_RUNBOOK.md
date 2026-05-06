# Avatar Engine V4 — Rive Import QA Runbook

## 1. Import file

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\import_avatar_v4_base_rive.ps1 -SourcePath "C:\path\to\base_avatar.riv"
```

## 2. Static verify

```powershell
.\tools\verify_avatar_v4_base_rive.ps1
```

Expected:

```text
base_avatar.riv exists
base_avatar.riv is not empty
handoff JSON exists
handoff docs exist
```

## 3. Flutter verify

```powershell
flutter analyze
flutter test
```

Expected:

```text
No issues found
All tests passed
```

## 4. Runtime verify

```powershell
flutter run
```

Choose your target device.

Expected:

```text
Home loads
Home does not show retired V3 blob avatar
Avatar customizer opens
Missing-rig diagnostic is gone
Rive avatar appears
Reference photo panel remains present
```

## 5. Visual QA

Check the avatar at these sizes:

```text
96px
180px
220px
512px
```

Confirm:

```text
hair not beard-like
hair not over mouth/chin
facial hair positioned correctly
glasses/accessories aligned
face readable
body respectful
skin details respectful
```

## 6. Bad import recovery

If the rig fails:

```text
1. Remove assets/avatar_rive/base_avatar.riv
2. Put the failed file somewhere outside assets/
3. Run flutter test
4. App should return to missing-rig diagnostic
5. Fix the .riv file, not the app contract
```
