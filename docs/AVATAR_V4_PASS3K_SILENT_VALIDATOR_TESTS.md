# Avatar V4 Pass 3K — Silent Validator Tests

Pass 3K removes the remaining noisy Rive warning from pure Dart tests.

## Why

The invalid-byte validator test intentionally verifies `unreadableAsset`. Calling `RiveFile.import()` in that test causes Rive to warn about initialization even though native initialization is disabled to avoid `rive_common_plugin.dll` issues on Windows.

## Change

`AvatarRiveContractValidator` now accepts:

```dart
parseRiveFile: false
```

for pure Dart tests.

Production default remains:

```dart
parseRiveFile: true
initializeNativeRuntime: true
```

So runtime behaviour is unchanged.

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\apply_avatar_v4_pass3k_silent_validator_tests.ps1
flutter analyze
flutter test
```
