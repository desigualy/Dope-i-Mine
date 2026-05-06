# Avatar V3 Pass 2C Test Repair

Fixes the failing Pass 2C tests.

The previous tests looked for phrases that were in Dart comments near the SVG constants, not inside the SVG string returned at runtime. This repair checks for actual SVG comment markers that exist inside the strings.

Run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\repair_avatar_v3_pass2c_tests.ps1
flutter analyze
flutter test
```
