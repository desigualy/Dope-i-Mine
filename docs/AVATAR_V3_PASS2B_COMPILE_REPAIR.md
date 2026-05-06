# Avatar V3 Pass 2B Compile Repair

Fixes the compile error:

- `imagePath` is not defined on `domain/user_avatar/UserAvatarProfile`
- `remoteImageUrl` is not defined on `domain/user_avatar/UserAvatarProfile`

The string-profile model only has string appearance fields, so Pass 2B now detects starter-like profiles from hair fields only.

Run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\repair_avatar_v3_pass2b_compile.ps1
flutter analyze
flutter test
```
