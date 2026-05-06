# Avatar Engine V4 — Pass 3F Connect Real Services

Pass 3F connects the reference-image customizer panel to real app services.

## What this pass changes

```text
AvatarCustomizerScreen no longer hardcodes:
  userId: null
  isOnline: false
  service: null
```

It now reads:

```text
avatarV4CurrentUserIdProvider
avatarV4OnlineProvider
avatarV4ReferenceImageServiceProvider
```

## Added provider file

```text
lib/avatar_engine_v4/providers/avatar_v4_providers.dart
```

## Provider responsibilities

```text
avatarV4OnlineProvider
  Uses connectivity_plus to check online/offline state.

avatarV4CurrentUserIdProvider
  Reads Supabase current user id when Supabase is initialized.

avatarV4ReferenceImageServiceProvider
  Builds AvatarV4ReferenceImageService when Supabase client is available.

avatarV4SyncServiceProvider
  Builds AvatarV4SyncService using SharedPreferences local cache and AvatarV4Repository.
```

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\apply_avatar_v4_pass3f_connect_real_services.ps1
flutter analyze
flutter test
```
