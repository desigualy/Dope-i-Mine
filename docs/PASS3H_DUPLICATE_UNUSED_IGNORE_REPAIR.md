# Pass 3H Duplicate Ignore Repair

The repo now has both:

```dart
// ignore_for_file: unused_element
```

and an old inline:

```dart
// ignore: unused_element
```

Analyzer correctly reports the inline ignore as duplicate.

This repair removes the stale inline ignore and keeps the file-level ignore.

## Run

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\repair_pass3h_duplicate_unused_ignore.ps1
flutter analyze
flutter test
```
