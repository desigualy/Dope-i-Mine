# Avatar Engine V4 — Pass 3E Reference Image Upload Flow

Pass 3E adds the upload path for user reference photos.

## Rules implemented

```text
Reference image upload requires online state.
Reference image upload requires explicit consent.
Reference image upload requires a signed-in user id.
Only metadata and storage path are registered in avatar_uploads.
```

## Added files

```text
lib/avatar_engine_v4/domain/avatar_v4_reference_image_upload.dart
lib/avatar_engine_v4/data/avatar_v4_reference_image_storage.dart
lib/avatar_engine_v4/data/avatar_v4_reference_image_service.dart
lib/avatar_engine_v4/presentation/avatar_reference_image_panel.dart
supabase/migrations/202605060002_avatar_reference_storage.sql
test/avatar_v4/avatar_v4_reference_image_service_test.dart
test/avatar_v4/avatar_v4_reference_image_panel_test.dart
```

## Storage bucket

```text
avatar-reference-images
```

## Storage path convention

```text
avatar_uploads/<user_id>/<timestamp>_reference.<ext>
```

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\apply_avatar_v4_pass3e_reference_image_flow.ps1
flutter pub get
flutter analyze
flutter test
```

Because this repo has Supabase migration-history drift, apply this SQL manually in Supabase SQL Editor:

```text
supabase/migrations/202605060002_avatar_reference_storage.sql
```
