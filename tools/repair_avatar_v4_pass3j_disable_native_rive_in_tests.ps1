$ErrorActionPreference = "Stop"

$patchRoot = Split-Path -Parent $PSScriptRoot
$projectRoot = Get-Location

Write-Host "Repairing Avatar V4 Pass 3J by disabling native Rive init in pure Dart tests..."

$files = @(
  "lib\avatar_engine_v4\runtime\avatar_rive_runtime_initializer.dart",
  "lib\avatar_engine_v4\runtime\avatar_rive_contract_validator.dart",
  "test\avatar_v4\avatar_v4_rive_contract_validator_test.dart",
  "test\avatar_v4\avatar_v4_rive_runtime_initializer_test.dart"
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

Write-Host "Avatar V4 Pass 3J pure-Dart test repair applied."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
