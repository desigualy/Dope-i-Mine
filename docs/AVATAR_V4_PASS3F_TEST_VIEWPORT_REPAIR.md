# Avatar V4 Pass 3F Test Viewport Repair

The previous scroll repair was not enough because the test render root remained 800x600 and the checkbox centre stayed at y=636.

This repair increases the test viewport only for the affected widget test:

```dart
tester.view.physicalSize = const Size(800, 1000);
tester.view.devicePixelRatio = 1.0;
addTearDown(tester.view.resetPhysicalSize);
addTearDown(tester.view.resetDevicePixelRatio);
```

This keeps the production UI unchanged and fixes the test hit target.

## Run

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\repair_avatar_v4_pass3f_test_viewport.ps1
flutter analyze
flutter test
```
