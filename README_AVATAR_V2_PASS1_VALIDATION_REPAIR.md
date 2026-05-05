# Avatar V2 Pass 1 Validation Repair

This fixes the remaining test failure:

`child avatars normalize facial hair to none`

## Root cause

`AvatarV2Profile.copyWith()` was already stripping facial hair when age was set to child/pre-teen.

That meant `AvatarV2Validation.validate()` never saw the invalid state, so it could not emit the expected warning.

## Correct ownership

`copyWith()` should only copy fields.

`AvatarV2Validation.validate()` owns normalization and warnings.

## Apply

From project root:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\fix_avatar_v2_pass1_validation.ps1
flutter analyze
flutter test
```
