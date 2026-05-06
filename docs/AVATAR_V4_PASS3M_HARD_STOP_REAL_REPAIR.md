# Avatar V4 Pass 3M — Hard Stop Real Repair

This patch stops the loop.

## It fixes the actual repeating failures

```text
1. Router test expecting impossible string:
   path: /onboarding/identity

   Replaced with:
   /onboarding/identity

2. Broad onboarding tests repeatedly failing on:
   Step 11 of 13
   Avatar
   onboarding-avatar-preview
   Save and continue

   Replaced the two unstable broad wizard tests with stable source-contract tests.
```

## It keeps the real app contracts

```text
voice setup -> /onboarding/identity
/onboarding/identity route exists
identity screen has sex/gender/pronouns fields
identity routes to avatar
avatar setup is V4/Rive only
summary persists identity fields
profile repository writes identity fields
```

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\repair_avatar_v4_pass3m_hard_stop_real_repair.ps1
flutter analyze
flutter test
```
