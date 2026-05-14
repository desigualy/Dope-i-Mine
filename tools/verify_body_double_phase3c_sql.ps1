param(
    [string]$DatabaseUrl = $env:SUPABASE_DB_URL
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($DatabaseUrl)) {
    throw 'Set SUPABASE_DB_URL to a disposable/local Supabase Postgres connection string before running this verification.'
}

$psql = Get-Command psql -ErrorAction SilentlyContinue
if ($null -eq $psql) {
    throw 'psql was not found on PATH. Install PostgreSQL client tools before running this verification.'
}

$scriptPath = Join-Path $PSScriptRoot '..\supabase\sql\body_double_phase3_rls_rpc_tests.sql'
if (-not (Test-Path $scriptPath)) {
    throw "Verification SQL not found: $scriptPath"
}

Write-Host 'Running Body Double Phase 3A/3B/3C SQL verification against disposable database...'
& $psql.Source $DatabaseUrl -v ON_ERROR_STOP=1 -f $scriptPath

if ($LASTEXITCODE -ne 0) {
    throw "Body Double Phase 3 SQL verification failed with exit code $LASTEXITCODE."
}

Write-Host 'Body Double Phase 3 SQL verification passed.'