# Avatar V3 Pass 1 Compile Repair

Fixes:

- Adds `flutter_svg` and `vector_graphics` to `pubspec.yaml` robustly.
- Repairs `AvatarV3Migration` so it no longer references legacy enum members that do not exist in the current repo.
- Maps legacy skin tone from `Color`, because the current legacy profile stores `skinTone` as a `Color`, not an enum.

Run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\fix_avatar_v3_pass1_compile.ps1
flutter pub get
flutter analyze
flutter test
```
