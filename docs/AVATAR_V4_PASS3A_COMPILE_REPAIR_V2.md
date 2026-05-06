# Avatar V4 Pass 3A Compile Repair V2

Fixes:

- non-constant `AvatarRiveAssetResolver` default in `AvatarRiveView`
- `rootBundle` name collision inside resolver initializer
- old test parameter name `rootBundle`

Run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\repair_avatar_v4_pass3a_compile_v2.ps1
flutter analyze
flutter test
```
