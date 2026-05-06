# Avatar V4 Pass 3M Green Lock

Locked at: 2026-05-06 21:34:53 +01:00

## Verification

`	ext
flutter analyze -> No issues found
flutter test    -> All tests passed
`

## Locked Contracts

`	ext
Avatar V4 / Rive path is active.
Old public Avatar V3 onboarding surface is retired.
Onboarding includes Sex, Gender & Pronouns identity step.
Voice setup routes to /onboarding/identity.
Identity routes to /onboarding/avatar.
Avatar setup routes to /onboarding/summary.
Router exposes /onboarding/identity.
Onboarding summary persists identity fields.
Profile repository writes:
- sex_at_birth
- gender_identity
- pronouns
- custom_pronouns
`

## Do Not Re-run

Do not re-run Pass 3M repair scripts unless a future change deliberately touches onboarding identity, avatar setup, or route wiring.

## Next Safe Work

Proceed only from this green state.