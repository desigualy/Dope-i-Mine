# Dope-i-Mine Manual-to-Automated QA Matrix

## Purpose

This matrix defines which checks should be automated and which should remain manual until device/runtime behaviour is stable.

## Automate first

| Area | Manual check to replace | Automated target |
|---|---|---|
| App boot | App opens without red screen | `flutter test`, `integration_test/app_boot_flow_test.dart` |
| Routing | Normal user routes home | widget/router test |
| Routing | Unconfirmed caregiver routes confirmation | widget/router test |
| Routing | Confirmed caregiver routes dashboard | widget/router test |
| Tasks | User creates task | widget/integration test |
| Task breakdown | Breakdown steps render | widget/integration test |
| Progress | Step completion persists | repository/widget test |
| Side quests | Toggle hides/shows side quests | widget test |
| Body double | Dope-i session start/pause/resume/end | widget/controller test |
| Known-person body double | Invite accept/decline | controller/widget test |
| Random body double | Unsafe modes blocked | domain/SQL test |
| Group body double | Max size enforced | domain/SQL test |
| Moderation | Report review/restrict/revoke | SQL/repository/widget test |
| Notifications | Read/dismiss state | repository/widget/SQL test |
| Offline sync | Pending action survives reload | local store/unit test |
| Accessibility | Toggles persist | repository/widget test |

## Keep manual for now

| Area | Why manual remains useful |
|---|---|
| Real microphone quality | Device/audio stack varies |
| Real TTS voice quality | OS voice availability varies |
| Android notification permission UI | OS version/manufacturer varies |
| Notification tap from killed app | Native lifecycle needs device validation |
| Email delivery | Supabase/project email limits vary |
| Avatar visual quality | Human visual review required |
| Sensory feel | Human review required |
| Release APK install | Real device/signing validation required |

## Pass rule

A phase is not complete unless:

- `flutter analyze` passes.
- `flutter test` passes.
- relevant SQL/RLS tests pass.
- release/build gate status is reported.
- remaining manual checks are explicitly listed.
