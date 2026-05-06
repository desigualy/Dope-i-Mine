# Avatar V4 Pass 3M — Replace Broken Tests

This patch replaces the two corrupted test files directly instead of trying to regex-patch them again.

## Replaced

```text
test/onboarding/onboarding_flow_test.dart
test/avatar_v4/avatar_v4_onboarding_purge_test.dart
```

## Fixed failures

```text
Expected: contains 'path: /onboarding/identity'
Expected: Your personal avatar
Expected: Summary
Step-position failures caused by inserted identity route
```

## Preserved contracts

```text
/onboarding/identity exists
identity_screen.dart is imported
IdentityScreen is routed
voice setup routes to /onboarding/identity
identity screen contains sex/gender/pronouns fields
avatar setup is V4/Rive-only
profile save path contains identity fields
```

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\repair_avatar_v4_pass3m_replace_broken_tests.ps1
flutter analyze
flutter test
```
