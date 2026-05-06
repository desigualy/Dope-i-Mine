$ErrorActionPreference = "Stop"

$patchRoot = Split-Path -Parent $PSScriptRoot
$projectRoot = Get-Location

Write-Host "Repairing Avatar V4 missing-rig diagnostic overflow..."

$relative = "lib\avatar_engine_v4\presentation\avatar_missing_rig_diagnostic.dart"
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

Write-Host "Avatar V4 diagnostic overflow repair applied."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
