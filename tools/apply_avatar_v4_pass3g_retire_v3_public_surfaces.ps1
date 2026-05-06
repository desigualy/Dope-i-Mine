$ErrorActionPreference = "Stop"

$patchRoot = Split-Path -Parent $PSScriptRoot
$projectRoot = Get-Location

Write-Host "Applying Avatar V4 Pass 3G V3 public-surface retirement..."

$files = @(
  "lib\avatar_engine_v4\domain\avatar_v4_retirement_policy.dart",
  "lib\avatar_engine_v4\avatar_engine_v4.dart",
  "test\avatar_v4\avatar_v4_v3_retirement_test.dart"
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

Write-Host "Avatar V4 Pass 3G V3 public-surface retirement applied."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
