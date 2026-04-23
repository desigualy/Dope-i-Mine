# iOS Permissions and Info.plist Notes

Add or verify the following keys in `ios/Runner/Info.plist`:

- `NSMicrophoneUsageDescription`
- `NSSpeechRecognitionUsageDescription`
- user-facing notification permission rationale where relevant

## Recommended copy
Microphone:
'Dope-i-Mine uses the microphone so you can speak tasks instead of typing them.'

Speech recognition:
'Dope-i-Mine uses speech recognition to turn spoken tasks into manageable steps.'

## Practical notes
- TTS does not usually need special permission.
- STT does.
- Notifications require user authorization in-app.
