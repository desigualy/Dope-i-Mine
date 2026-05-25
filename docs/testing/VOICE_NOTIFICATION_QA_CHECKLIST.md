# Voice and Notification QA Checklist

| Check | Expected result | Pass/Fail | Notes |
| --- | --- | --- | --- |
| Open voice settings test panel | Panel opens from setup/settings. |  |  |
| STT starts | Listening starts only after user action. |  |  |
| STT stops | Stop control ends listening. |  |  |
| TTS starts | App reads selected text/step aloud. |  |  |
| TTS stops | Stop control ends speaking. |  |  |
| Task input accepts spoken text | Spoken text appears in task input. |  |  |
| Task step can be read aloud | Step TTS works. |  |  |
| Voice failure occurs | App shows understandable failure and does not crash. |  |  |
| Microphone denied | Denied state is understandable and recoverable. |  |  |
| Notification permission request works | Android prompt appears and app handles allow/deny. |  |  |
| Local notification appears | Local notification is delivered when enabled and allowed. |  |  |
| Notification tap opens route | Tap opens the expected app route. |  |  |
| Caregiver assignment notification | Opens assigned task. |  |  |
| Body-double invite notification | Opens invite/session screen. |  |  |
| Routine reminder notification | Opens routine. |  |  |
| Task reminder notification | Opens task. |  |  |
| Notifications disabled | No crash; user can re-enable later. |  |  |
| Quiet hours enabled where implemented | Local delivery is suppressed during quiet hours. |  |  |

