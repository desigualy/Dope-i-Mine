# Avatar V4 Pass 3M Final Test Repair

This repairs the remaining test drift after onboarding changed.

## Fixes

```text
1. Broad onboarding tests no longer expect the unstable title text "Avatar".
2. They now assert the stable V4 onboarding key:
   onboarding-avatar-preview
3. Tests no longer click "Next" from the avatar page, because Avatar uses "Continue".
4. The router source-contract test now checks /onboarding/identity directly.
5. Remaining double-quote lint is cleared.
```

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\repair_avatar_v4_pass3m_final_test_repair.ps1
flutter analyze
flutter test
```
