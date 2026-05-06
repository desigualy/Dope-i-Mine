# Avatar V4 Pass 3M — Purge Old Onboarding Avatar + Add Sex/Gender/Pronouns

## What this pass does

```text
Purges the old avatar creator/candidate/preview system from onboarding.
Replaces onboarding avatar with Avatar Engine V4 / Rive only.
Adds sex at birth, gender, pronouns, and custom pronouns to onboarding state.
Adds a dedicated Sex, gender & pronouns onboarding screen.
Adds identity row to onboarding summary.
Adds optional persistence fields to users_profile.
```

## Old onboarding avatar surfaces removed from onboarding

```text
AvatarCreatorScreen
AvatarCandidateSelectorScreen
AvatarPreviewCard
currentUserAvatarConfigProvider
SupabaseAvatarBatchGenerator
domain/avatar/user_avatar_profile.dart
```

## New onboarding route

```text
/onboarding/identity
```

Flow:

```text
voice setup → sex/gender/pronouns → avatar → summary
```

## Supabase SQL

Apply manually because migration history is drifted:

```text
supabase/migrations/202605060003_profile_identity_fields.sql
```

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\apply_avatar_v4_pass3m_purge_onboarding_old_avatar_add_identity.ps1
flutter analyze
flutter test
```
