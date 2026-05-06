# Avatar V4 Pass 3M — Remove Bad `pumpApp` Test Repair

The previous repair inserted a direct route smoke test using:

```dart
pumpApp(...)
```

but `test/onboarding/onboarding_flow_test.dart` does not define that helper.

This repair removes only that invalid inserted test block.

It does **not** undo the real onboarding fixes:

```text
/onboarding/identity route remains
voice setup still routes to identity
old avatar onboarding purge remains
sex/gender/pronouns screen remains
```

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\repair_avatar_v4_pass3m_remove_bad_pumpapp_test.ps1
flutter analyze
flutter test
```
