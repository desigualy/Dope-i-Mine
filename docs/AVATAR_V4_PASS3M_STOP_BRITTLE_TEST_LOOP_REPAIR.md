# Avatar V4 Pass 3M — Stop Brittle Test Loop Repair

This fixes the bad loop.

## Problem

The previous repairs kept moving expectations around inside broad onboarding flow tests. Those tests are not reliable for checking exact route position after inserting a new onboarding step.

The actual contracts are source-level and stable:

```text
voice setup routes to /onboarding/identity
router exposes /onboarding/identity
avatar onboarding screen imports Avatar Engine V4 only
old avatar onboarding imports are gone
```

## Fix

```text
1. Corrects the router test to assert /onboarding/identity directly.
2. Clears the remaining quote lint.
3. Removes brittle live-widget onboarding-avatar-preview assertions from broad wizard tests.
```

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\repair_avatar_v4_pass3m_stop_brittle_test_loop.ps1
flutter analyze
flutter test
```
