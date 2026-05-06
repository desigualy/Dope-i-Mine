# Restore `validateLoginPassword`

The previous patch changed `LoginScreen` to call `validateLoginPassword`, but your current `auth_validators.dart` did not contain that function.

This repair:

- adds `validateLoginPassword(String value)`
- keeps `validatePassword(String value)` for signup/reset strength rules
- ensures `LoginScreen` imports `auth_validators.dart`
- ensures login calls `validateLoginPassword(_passwordController.text)`

Run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\restore_validate_login_password.ps1
flutter analyze
flutter test
```
