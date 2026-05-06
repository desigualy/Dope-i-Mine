# Pass 3M IdentityScreen Import Unblock

Fixes the current compile error:

```text
The name 'IdentityScreen' isn't a class
Couldn't find constructor 'IdentityScreen'
```

Cause:

```text
onboarding_flow_test.dart uses IdentityScreen in helper routers,
but does not import identity_screen.dart.
```

Apply:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\apply_pass3m_identityscreen_import_unblock.ps1
flutter analyze
flutter test
```
