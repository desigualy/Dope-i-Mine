# Dope-i-Mine Pass 12 — Analyze Fix Pack

This pack fixes the actual analyzer-breaking issues reported from the first real Flutter environment pass:

- ambiguous `AuthUser` import in auth repository
- invalid `AuthUser(...)` construction due to import collision
- missing pronunciation extension import in onboarding summary
- unnecessary non-null assertion in overwhelm controller

It also relaxes non-critical analyzer noise for now so the app can move toward first successful build:
- deprecated member warnings
- async context lint
- trailing comma lint
- const constructor preference lint

Use this pack as the next base, then run:

flutter pub get
flutter analyze
flutter test
