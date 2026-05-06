# Avatar V4 Pass 3F Test Scroll Repair

The test failure is not a runtime service-wiring failure.

The consent checkbox was below the 800x600 test viewport:

```text
Offset(400.0, 636.0) is outside the bounds of the root of the render tree, Size(800.0, 600.0)
```

So the tap missed, consent stayed false, and the upload button stayed disabled.

## Fix

The test now scrolls the customizer before tapping:

```dart
await tester.scrollUntilVisible(
  find.byKey(const ValueKey<String>('avatar-v4-reference-consent')),
  220,
  scrollable: find.byType(Scrollable).first,
);
```

## Run

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\repair_avatar_v4_pass3f_test_scroll.ps1
flutter analyze
flutter test
```
