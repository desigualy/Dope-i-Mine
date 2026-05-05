# Avatar V2 Pass 1 Compile Repair

This repair fixes the two compile blockers reported after applying Avatar V2 Pass 1:

1. `AvatarV2HairStyle.taperedCoils` missing from an exhaustive switch in:
   `lib/domain/avatar_v2/avatar_v2_options.dart`

2. `_isCurlyAfroHair` referenced but missing inside:
   `lib/presentation/user_avatar/user_avatar_renderer.dart`

## Apply from project root

PowerShell:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\fix_avatar_v2_pass1_compile.ps1
flutter analyze
flutter test
```

The script is idempotent: if the fixes are already present, it will not duplicate them.
