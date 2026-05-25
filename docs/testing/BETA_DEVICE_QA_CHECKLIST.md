# Beta Device QA Checklist

| Check | Expected result | Pass/Fail | Notes |
| --- | --- | --- | --- |
| Install debug APK on Android emulator | APK installs and launches. |  |  |
| Install debug APK on physical Android device | APK installs and launches. |  |  |
| Launch after fresh install | App opens without red screen. |  |  |
| Launch after app restart | Last valid auth/setup route is preserved. |  |  |
| Launch after force close | App opens without data loss or crash. |  |  |
| Launch after device reboot | App opens and routes correctly. |  |  |
| Verify Android notification permission prompt | Prompt copy is understandable and app survives allow/deny. |  |  |
| Verify microphone permission prompt | Prompt appears only from voice action and app survives allow/deny. |  |  |
| Deny notification permission | App does not crash and shows in-app/settings guidance where available. |  |  |
| Deny microphone permission | App does not crash and voice setup explains the denied state. |  |  |
| Use poor network | Core screens remain usable or show clear pending/error state. |  |  |
| Use offline | Offline-capable flows remain usable; online-only flows do not fake success. |  |  |
| Build debug APK | `flutter build apk --debug` passes when required. |  |  |
| Build release APK | `flutter build apk --release` passes for release gate. |  |  |

