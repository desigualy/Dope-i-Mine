# Flutter Shell Bootstrap

Because this repo was generated in staged passes, the Dart/app layer is more complete than the native Android/iOS shell.

## Why this matters
Without the standard Flutter host project files, you cannot do a full build.

## Fix
Run:

```bash
bash tool/bootstrap_flutter_shell.sh
```

This will:
- generate Android/iOS host files with `flutter create .`
- restore the existing app source after generation
- run `flutter pub get`

## After bootstrap
Run:

```bash
flutter analyze
flutter test
flutter run --dart-define-from-file=.env.json
```

## Important
Still review:
- AndroidManifest permissions
- iOS Info.plist strings
- Supabase env values
- notification setup
- STT/TTS runtime permissions
