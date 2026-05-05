# Avatar V3 Pass 1 Repair 2

This repair fixes the current log:

- Removes `lib/presentation/avatar_v2`
- Removes `test/avatar_v2`
- Adds `flutter_svg`
- Adds `vector_graphics`
- Adds `assets/avatar_v3/` to pubspec assets

The previous repair script failed because it was run after extraction into the project root, so it attempted to copy `avatar_v3_migration.dart` onto itself and stopped before pubspec was updated.

Run from project root:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\repair_avatar_v3_pass1_after_apply.ps1
flutter pub get
flutter analyze
flutter test
```
