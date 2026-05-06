# Avatar Engine V4 — Pass 3H Analyzer Cleanup

Pass 3H removes the current harmless analyzer noise without changing Avatar V4 runtime behaviour.

## Fixes

```text
prefer_single_quotes in AvatarV4RetirementPolicy
unused _resolveBreakdownFocus warning
prefer_const_declarations in old V3 files/tests
```

## Why old V3 files are handled with ignore headers

The V3 renderer is retired from public use but still exists in the repo for migration/test safety. This pass does not alter old V3 behaviour; it only silences non-blocking style info from retired files.

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\apply_avatar_v4_pass3h_analyzer_cleanup.ps1
flutter analyze
flutter test
```
