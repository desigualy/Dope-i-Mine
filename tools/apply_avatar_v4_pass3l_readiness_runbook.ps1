$ErrorActionPreference = "Stop"

$patchRoot = Split-Path -Parent $PSScriptRoot
$projectRoot = Get-Location

Write-Host "Applying Avatar V4 Pass 3L readiness report + runbook..."

$files = @(
  "docs\avatar_rive\AVATAR_V4_FINAL_READINESS_REPORT.md",
  "docs\avatar_rive\AVATAR_V4_TEST_RUNBOOK_AFTER_RIVE_IMPORT.md",
  "docs\avatar_rive\AVATAR_V4_NEXT_PASSES.md",
  "lib\avatar_engine_v4\domain\avatar_v4_readiness_report.dart",
  "lib\avatar_engine_v4\avatar_engine_v4.dart",
  "test\avatar_v4\avatar_v4_readiness_report_test.dart"
)

foreach ($relative in $files) {
  $source = Join-Path $patchRoot $relative
  $target = Join-Path $projectRoot $relative

  if (!(Test-Path $source)) {
    throw "Missing patch file: $source"
  }

  $sourceResolved = (Resolve-Path $source).Path
  $targetResolved = if (Test-Path $target) { (Resolve-Path $target).Path } else { $target }

  if ($sourceResolved -ne $targetResolved) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
    Copy-Item -Force $source $target
    Write-Host "Patched $relative"
  } else {
    Write-Host "Already patched $relative"
  }
}

Write-Host "Avatar V4 Pass 3L readiness report + runbook applied."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
