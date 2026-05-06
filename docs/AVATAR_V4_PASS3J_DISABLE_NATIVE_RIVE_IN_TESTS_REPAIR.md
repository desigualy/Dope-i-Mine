# Avatar V4 Pass 3J — Disable Native Rive Init in Pure Dart Tests

The Windows test runner does not provide:

```text
rive_common_plugin.dll
```

Calling `RiveFile.initialize()` in pure Dart tests can throw and then hang the test isolate.

This repair adds:

```dart
AvatarRiveRuntimeInitializer.setNativeInitializationEnabledForTesting(false)
```

and gives `AvatarRiveContractValidator` an `initializeNativeRuntime` flag for tests.

Runtime behaviour stays unchanged. Production still initializes Rive before rendering. Pure Dart tests do not try to load the native Rive DLL.

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\repair_avatar_v4_pass3j_disable_native_rive_in_tests.ps1
flutter analyze
flutter test
```
