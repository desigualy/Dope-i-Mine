# Build and Release Flow

## Development
- flutter pub get
- flutter analyze
- flutter test
- flutter run --dart-define-from-file=.env.json

## Android release candidate
- verify manifest permissions
- generate icons
- flutter build appbundle --release --dart-define-from-file=.env.json

## iOS release candidate
- verify Info.plist permission strings
- verify signing/provisioning
- flutter build ipa --release --dart-define-from-file=.env.json

## Before store submission
- replace placeholder assets
- test reminders on real devices
- test microphone/STT on real devices
- verify onboarding and task flows end-to-end
