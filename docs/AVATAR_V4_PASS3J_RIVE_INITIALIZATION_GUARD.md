# Avatar Engine V4 — Pass 3J Rive Initialization Guard

Pass 3J adds a small runtime initializer so Rive is initialized before contract validation or rendering.

## Why

Rive can warn when `RiveFile.import()` is called before `RiveFile.initialize()`.

Pass 3J adds:

```text
AvatarRiveRuntimeInitializer.ensureInitialized()
```

and calls it before:

```text
AvatarRiveContractValidator imports/parses .riv bytes
AvatarRiveView renders the RiveAnimation
```

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\apply_avatar_v4_pass3j_rive_initialization_guard.ps1
flutter analyze
flutter test
```
