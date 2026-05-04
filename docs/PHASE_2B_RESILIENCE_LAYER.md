# Phase 2B — Offline Resilience Layer

## Purpose

Dope-i-Mine must keep working when the network, Supabase, avatar generation, or sync path fails.

## Implemented in this patch

- Connectivity status controller
- Offline status banner in the primary scaffold
- SharedPreferences-backed local stores
- Sync queue with idempotency keys
- Sync status panel in Settings
- Offline-first task repository wrapper
- Local task fallback when Supabase/network fails
- Local step completion and XP award fallback
- Offline avatar fallback candidate store
- Local profile and routine cache scaffolds

## Product rule

Network access should improve Dope-i-Mine, not be required for the core task-support flow.

## Manual validation

1. Run the app online.
2. Create and complete a task.
3. Turn off network.
4. Create `put washing away`.
5. Confirm relevant steps appear.
6. Complete one step.
7. Confirm UI updates and does not crash.
8. Open Settings and confirm offline/sync status appears.
9. Restore network.
10. Press Retry sync.

## Notes

The sync engine currently safely syncs remote step completions. Local-to-remote task ID reconciliation is intentionally held queued until the dedicated task reconciliation pass is added.
