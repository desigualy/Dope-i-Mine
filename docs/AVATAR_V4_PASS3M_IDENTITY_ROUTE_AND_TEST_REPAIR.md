# Avatar V4 Pass 3M Identity Route + Test Repair

The previous test patch inserted the identity-step expectation too broadly.

This repair:

```text
1. Forces voice setup Next to route to /onboarding/identity.
2. Ensures /onboarding/identity exists in the router.
3. Removes the misplaced identity expectation from the home-avatar-entry test.
4. Adds a direct identity route smoke test.
```

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\repair_avatar_v4_pass3m_identity_route_and_test.ps1
flutter analyze
flutter test
```
