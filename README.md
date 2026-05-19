# Dope-i-Mine

Dope-i-Mine is a Flutter wellbeing and executive-function support app. It helps users turn overwhelming tasks into clear, manageable steps with task breakdowns, minimum-path mode, side quests, rewards, routines, reminders, caregiver support, body-doubling flows, voice input/output, and avatar/mascot support.

This is not a diagnostic or medical app. It is a practical support tool for daily task initiation, planning, and follow-through.

## Current repository state

Last reviewed from `main`: 2026-05-19.

The repository is an active integration build, not a confirmed release build. The app has a broad production-shaped structure, but several runtime surfaces still require debugging, real-device QA, and validation before release.

Phase 2 repo-lock status: complete on `main` as of commit `8b84d100fb69b2f6a1f298bd2ea7ae5a0a3b725e`.

Phase 2 deployment-safe status: local validation and targeted Supabase deployment passed. Manual end-to-end QA is still required before release.

Current stack:

- Flutter / Dart
- Riverpod
- GoRouter
- Supabase Auth, Database, Storage, and Edge Functions
- `speech_to_text`
- `flutter_tts`
- `flutter_local_notifications`
- Rive avatar runtime support
- Offline-first task fallback and sync queue foundations

## What is currently present

The repo currently includes:

- App shell, routing, theme, onboarding, auth, settings, and home flows
- Supabase-aware startup with optional local/offline fallback for some task flows
- Task input and task breakdown screens
- Deep household task templates, including laundry, washing up, hoovering, bed making, washing machine, bin, and room reset flows
- Minimum-version mode for low-energy task completion
- Overwhelm support UI and calm-mode handling
- Side quest repository/UI foundations
- Reward and XP foundations
- Body-double start/session/summary/moderation screens
- Caregiver dashboard, linking, assignment, permissions, and progress insight screens
- Routine list/detail/builder/run screens
- Voice service layer and speech input controller foundations
- Android microphone and notification permissions
- Dope-i mascot mood asset paths
- Avatar Engine V4 Rive contract, validator, runtime wrapper, and missing-rig diagnostic
- Supabase Edge Functions for task creation, step breakdown, overwhelm rescue, caregiver invite, and avatar candidate generation

## Phase 2 repo lock

Phase 2 repository lock is enforced by:

- `.github/workflows/flutter.yml` — GitHub Actions workflow that runs `flutter pub get`, `flutter analyze`, and `flutter test` on push and pull request.
- `supabase/migrations/202605150004_caregiver_temporary_password_gate.sql` — idempotent migration for the caregiver temporary-password gate.

The caregiver temporary-password gate migration adds:

- `public.users_profile.must_change_password`
- `public.users_profile.temporary_password_created_at`
- `public.caregiver_email_invites.temporary_password_set_at`
- `public.caregiver_email_invites.requires_password_setup`
- `public.caregiver_email_invites.password_setup_sent_at`
- `users_profile_must_change_password_idx`

The migration ends with `pg_notify('pgrst', 'reload schema')` so PostgREST refreshes its schema cache after deployment.

Latest Phase 2 lock validation:

```bash
flutter pub get
flutter analyze
flutter test
npx supabase db push
npx supabase functions deploy send-caregiver-invite
```

Result from the final lock pass:

- `flutter pub get`: pass
- `flutter analyze`: pass
- `flutter test`: pass (`151` tests passed)
- `npx supabase db push`: pass; remote database reported up to date
- `npx supabase functions deploy send-caregiver-invite`: pass

## Known debugging priorities

### 1. Validate the current local build

Run these before claiming any feature is complete:

```bash
flutter pub get
flutter analyze
flutter test
```

Known recent blocker:

- `test/onboarding/onboarding_flow_test.dart` can fail if `_FakeAuthRepository` is stale and does not implement `updatePassword(String password)` after `AuthRepositoryImpl` gained that method.

Expected fix:

```dart
@override
Future<void> updatePassword(String password) async {}
```

Add it to the fake auth repository used in onboarding tests.

### 2. Supabase initialization and offline behaviour

`main.dart` only initializes Supabase when `SUPABASE_URL` and `SUPABASE_ANON_KEY` are supplied through Dart defines. Some providers are offline-safe, but others still require a Supabase client and will throw when accessed without initialization.

Run with:

```bash
flutter run --dart-define=SUPABASE_URL=your-url --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

or:

```bash
flutter run --dart-define-from-file=.env.json
```

Do not commit `.env`, `.env.json`, service-role keys, API keys, or secrets.

### 3. Voice is not fully wired yet

The repo has STT/TTS service foundations and a `VoiceInputButton`, but the full runtime wiring still needs completion.

Required checks:

- Task input must include working speech-to-text input.
- Task steps must include read-aloud controls.
- Voice settings must include a real STT/TTS test panel.
- Speaking and listening must always be stoppable.
- Android microphone permission must be tested on a real device.

### 4. Avatar Engine V4 still needs the real Rive rig

The app expects:

```text
assets/avatar_rive/base_avatar.riv
```

Required Rive contract:

```text
Artboard: Avatar
State machine: AvatarState
```

Required number inputs:

```text
skinTone
faceShape
hairPack
hairStyle
hairColor
bodyPreset
```

Required boolean inputs:

```text
freckles
vitiligo
hasFacialHair
hasGlasses
```

Until that production `.riv` file exists and passes the contract validator, the app should show the missing-rig diagnostic instead of a final avatar.

### 5. Side quest toggle needs runtime verification

Side quests are intended to be optional and toggleable. Confirm that turning side quests off hides all side quest prompts and panels, not just the heading text.

### 6. Step breakdown context needs tightening

Some breakdown/regeneration paths use a default snapshot instead of the user's selected support mode, energy level, stress level, and time availability. Confirm that follow-up breakdowns preserve the original task context.

### 7. Supabase Edge Function deployment needs verification

Use `npx` unless Supabase CLI is globally configured:

```bash
npx supabase db push
npx supabase functions deploy create-task
npx supabase functions deploy breakdown-step
npx supabase functions deploy overwhelm-rescue
npx supabase functions deploy send-caregiver-invite
npx supabase functions deploy generate-avatar-candidates
```

Required avatar generation secrets:

```text
OPENAI_API_KEY
OPENAI_IMAGE_MODEL
AVATAR_BUCKET
```

Required bucket:

```text
avatar-candidates
```

Also verify that shared function imports exist under `supabase/functions/_shared/` before deployment.

### 8. Repository hygiene

Generated/local-machine files should not be committed. Check for and remove local generated files such as:

```text
.flutter-plugins-dependencies
.idea/
.dart_tool/
build/
```

Make sure `.gitignore` excludes generated files, local IDE state, build outputs, and secrets.

## Recommended validation order

Use this order for each serious pass:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run --dart-define-from-file=.env.json
npx supabase db push
npx supabase functions deploy create-task
npx supabase functions deploy breakdown-step
npx supabase functions deploy overwhelm-rescue
npx supabase functions deploy send-caregiver-invite
npx supabase functions deploy generate-avatar-candidates
```

Then perform real-device QA:

- App boots without a red screen.
- Login and signup work.
- Onboarding completes and survives restart.
- Task creation works online and offline.
- Task breakdowns are useful and not shallow.
- Minimum-path mode works.
- Side quests can be switched off.
- Rewards update after step completion.
- Overwhelm support can be entered and exited.
- Body-double flows route correctly.
- Caregiver flows respect relationship permissions.
- Voice input works from task input.
- Step read-aloud works and can be stopped.
- Avatar selection/customization persists.
- Dope-i mascot moods update during task events.
- Notifications/reminders work on a physical Android device.

## Definition of done for this repo

A feature is not done until:

- It is wired into the UI.
- It persists correctly where persistence is expected.
- It survives app restart where applicable.
- It has no placeholder production logic.
- It passes `flutter analyze`.
- It passes `flutter test`.
- It has manual test steps.
- It works on a real device for hardware-dependent features.

## Current release status

Not release-ready yet.

The repo is structurally strong and close to a serious integration build, but release still depends on:

- Clean analyzer pass
- Clean test pass
- Real `.riv` avatar rig import and validation
- Full STT/TTS UI wiring
- Supabase migrations/functions verified against the target project
- Real-device Android QA
- Store metadata, legal text, signing, and final assets
