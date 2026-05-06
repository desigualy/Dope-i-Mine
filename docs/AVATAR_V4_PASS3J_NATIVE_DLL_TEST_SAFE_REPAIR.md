# Avatar V4 Pass 3J Native DLL-Safe Repair

On Windows test VM, `RiveFile.initialize()` can fail if:

```text
rive_common_plugin.dll
```

is unavailable.

This repair keeps runtime behavior safe by making the initializer return the error object instead of throwing/hanging.

## Effect

```text
validator returns unreadableAsset when Rive native initialization fails
AvatarRiveView shows the diagnostic instead of crashing
tests no longer timeout on missing native Rive DLL
```

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\repair_avatar_v4_pass3j_native_dll_test_safe.ps1
flutter analyze
flutter test
```
