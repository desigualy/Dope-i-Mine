# Phase 3L — Automated QA Harness & Acceptance Test Protocols

## Objective

Convert the current manual QA burden into repeatable automated gates.

## Gate A — Fast Local Gate

Run after every code pass.

```powershell
.\tools\qa\test_fast_gate.ps1
```

Runs:

```text
flutter pub get
flutter analyze
flutter test
```

Pass criteria:

```text
0 analyzer issues
all unit/widget tests pass
no critical skipped tests unless documented
```

## Gate B — SQL/RLS Gate

Run whenever migrations, RPCs, RLS, repository security, caregiver, body-double, notification, sync, or settings logic changes.

```powershell
.\tools\qa\test_sql_gate.ps1
```

Run without DB reset when already reset:

```powershell
.\tools\qa\test_sql_gate.ps1 -SkipDbReset
```

Pass criteria:

```text
npx supabase db reset passes unless skipped
all existing SQL files pass
missing future SQL files are reported as skipped
no admin fixture setup mixed into user runtime tests
```

## Gate C — Integration Smoke Gate

Run before merging a feature phase.

```powershell
.\tools\qa\test_integration_gate.ps1
```

This script runs existing `integration_test/*.dart` files and skips missing future files.

## Gate D — Android Debug Build Gate

```powershell
.\tools\qa\test_android_debug_gate.ps1
```

Pass criteria:

```text
debug APK builds
manifest/build config is valid enough for installation
```

## Gate E — Release Gate

```powershell
.\tools\qa\test_release_gate.ps1
```

Optional appbundle:

```powershell
.\tools\qa\test_release_gate.ps1 -BuildAppBundle
```

Pass criteria:

```text
flutter clean passes
pub get passes
analyze passes
test passes
debug APK builds
release APK builds
AAB builds if requested
```

## One-command local pass

```powershell
.\tools\qa\test_all_local_gates.cmd
```

Useful options:

```powershell
.\tools\qa\test_all_local_gates.cmd -SkipDbReset
.\tools\qa\test_all_local_gates.cmd -SkipSql
.\tools\qa\test_all_local_gates.cmd -SkipAndroidBuild
.\tools\qa\test_all_local_gates.cmd -BuildRelease
.\tools\qa\test_all_local_gates.cmd -BuildRelease -BuildAppBundle
```

## SQL suite separation rule

Keep these responsibilities separate:

```text
runtime/RLS app-user tests
moderator/admin tests
retention cleanup tests
notification RLS tests
sync RLS tests
accessibility/settings RLS tests
```

Do not put privileged admin fixture creation into normal user-flow SQL files.

## Required reporting format

Every phase completion report must include:

```text
Validation:
- flutter pub get: pass/fail
- flutter analyze: pass/fail
- flutter test: pass/fail
- npx supabase db reset: pass/fail/not run
- SQL/RLS tests: pass/fail/not run
- Android debug build: pass/fail/not run
- Android release build: pass/fail/not run

Manual checks still required:
- ...

Known remaining issues:
- ...
```
