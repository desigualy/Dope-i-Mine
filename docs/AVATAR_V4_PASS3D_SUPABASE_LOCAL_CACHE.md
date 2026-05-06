# Avatar Engine V4 — Pass 3D Supabase + Local Cache Wiring

Pass 3D wires the ownership and sync layer.

## Rules implemented

```text
Changing/updating avatar = online required
Using already-owned outfits/accessories = allowed offline from local cache
Purchased/unlocked items = synced to Supabase and cached locally
Uploaded reference image metadata = online required
```

## Added files

```text
lib/avatar_engine_v4/domain/avatar_v4_sync_failure.dart
lib/avatar_engine_v4/data/avatar_v4_supabase_repository.dart
lib/avatar_engine_v4/data/avatar_v4_sync_service.dart
supabase/migrations/202605060001_avatar_engine_v4.sql
test/avatar_v4/avatar_v4_sync_service_test.dart
test/avatar_v4/avatar_v4_supabase_contract_test.dart
```

## Supabase tables

```text
avatar_profiles
avatar_inventory
avatar_purchases
avatar_uploads
```

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\apply_avatar_v4_pass3d_supabase_local_cache.ps1
flutter analyze
flutter test
```

## Optional DB migration

```powershell
npx supabase db push
```
