# Android Permissions and Manifest Notes

Add or verify the following in `android/app/src/main/AndroidManifest.xml`:

## Common permissions
- `android.permission.INTERNET`
- `android.permission.RECORD_AUDIO`
- `android.permission.POST_NOTIFICATIONS` (Android 13+)

## Suggested service declarations
Only add notification receivers/services if your chosen plugin configuration requires them.

## Practical notes
- STT requires microphone permission and a working speech service on device.
- Notifications on Android 13+ need runtime permission.
- Internet permission is required for Supabase-backed flows.

## Release checklist
- confirm app label
- confirm launcher icon generation
- confirm package/applicationId
- verify no debug permissions linger
