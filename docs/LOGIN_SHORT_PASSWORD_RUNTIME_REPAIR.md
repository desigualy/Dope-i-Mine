# Login Short-Password Runtime Repair

The failing test shows this:

```text
Expected: not null
Actual: <null>
```

That means the fake auth repository was never reached. The likely cause is that the Login screen is still using the signup/new-password validator somewhere, which blocks existing short passwords before `signIn()` runs.

## Correct rule

- Signup/new password creation: require 8+ chars.
- Login for existing accounts: only reject empty password.
- Existing accounts with old shorter passwords must be allowed to attempt sign-in.

## Run

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\repair_login_short_password_runtime.ps1
flutter analyze
flutter test
```
