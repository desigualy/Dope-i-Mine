# Dope-i-Mine Phase 3L QA Harness Drop-in

This ZIP adds non-invasive QA scripts and testing protocol documents.

It does not modify Flutter app code, Supabase migrations, or existing tests.

## Files added

```text
tools/qa/qa_common.ps1
tools/qa/test_fast_gate.ps1
tools/qa/test_sql_gate.ps1
tools/qa/test_integration_gate.ps1
tools/qa/test_android_debug_gate.ps1
tools/qa/test_release_gate.ps1
tools/qa/test_all_local_gates.ps1
tools/qa/test_all_local_gates.cmd
docs/testing/PHASE_3L_AUTOMATED_QA_PROTOCOLS.md
docs/testing/MANUAL_TO_AUTOMATED_QA_MATRIX.md
```

## First run

From repo root:

```powershell
.\tools\qa\test_fast_gate.ps1
```

For all local gates:

```powershell
.\tools\qa\test_all_local_gates.cmd -SkipDbReset
```

Use `-SkipDbReset` if your local Supabase database is already reset and running.

## PowerShell execution policy

PowerShell execution policy may block `.ps1` files. The `.cmd` wrapper uses:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass
```

For individual `.ps1` files, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\qa\test_fast_gate.ps1
```
