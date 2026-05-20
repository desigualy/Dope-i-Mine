# Phase 3 Regression Harness

These tests are guardrail tests for Phase 3. They do not replace deeper unit, widget, integration, or SQL/RLS tests. They prevent accidental removal or unwiring of the Phase 3 runtime surfaces while the deeper implementation is built.

Run them with:

```bash
flutter test test/phase3
```

They cover:

- Dope-i/body-double route and screen contracts
- Caregiver temporary-password gate contracts
- Caregiver operations and progress visibility surfaces
- Voice STT/TTS runtime wiring
- Side quest toggle visibility
- Follow-up task breakdown context preservation
- Known-person body double consent and privacy contracts
- Random body double safety gate, queue, matching, moderation, and anonymous session contracts
