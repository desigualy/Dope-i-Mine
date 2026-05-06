# Avatar V4 Pass 3M Onboarding Test Contract Repair

Pass 3M changed onboarding from 12 steps to 13 steps by inserting:

```text
Sex, gender & pronouns
```

before the Avatar step.

The failing tests still expected:

```text
Step 10 of 12
Companion & avatar
```

This repair updates the test contract to:

```text
Step 10 of 13
Step 11 of 13
Step 12 of 13
Avatar
```

It also inserts checks for the new identity screen fields where the old test jumped directly from voice setup to avatar.

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\repair_avatar_v4_pass3m_onboarding_test_contract.ps1
flutter analyze
flutter test
```
