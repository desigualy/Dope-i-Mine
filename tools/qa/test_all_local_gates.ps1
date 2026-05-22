param(
  [switch]$SkipDbReset,
  [switch]$SkipSql,
  [switch]$SkipAndroidBuild,
  [switch]$BuildRelease,
  [switch]$BuildAppBundle
)
. "$PSScriptRoot\qa_common.ps1"
Assert-RepoRoot
Show-EnvironmentSummary
& "$PSScriptRoot\test_fast_gate.ps1"
if (-not $SkipSql) {
  if ($SkipDbReset) { & "$PSScriptRoot\test_sql_gate.ps1" -SkipDbReset } else { & "$PSScriptRoot\test_sql_gate.ps1" }
} else {
  Write-Warn "Skipping SQL gate."
}
& "$PSScriptRoot\test_integration_gate.ps1"
if (-not $SkipAndroidBuild) { & "$PSScriptRoot\test_android_debug_gate.ps1" } else { Write-Warn "Skipping Android debug build." }
if ($BuildRelease) {
  if ($BuildAppBundle) { & "$PSScriptRoot\test_release_gate.ps1" -BuildAppBundle } else { & "$PSScriptRoot\test_release_gate.ps1" }
}
