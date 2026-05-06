$ErrorActionPreference = "Stop"

$patchRoot = Split-Path -Parent $PSScriptRoot
$projectRoot = Get-Location

Write-Host "Applying Avatar V4 Pass 3C Rive asset contract..."

$files = @(
  "lib\avatar_engine_v4\domain\avatar_v4_rive_contract.dart",
  "lib\avatar_engine_v4\domain\avatar_v4_rig_status.dart",
  "lib\avatar_engine_v4\runtime\avatar_rive_controller.dart",
  "lib\avatar_engine_v4\domain\avatar_v4_config.dart",
  "lib\avatar_engine_v4\avatar_engine_v4.dart",
  "assets\avatar_rive\README.md",
  "assets\avatar_rive\avatar_v4_rive_contract.json",
  "test\avatar_v4\avatar_v4_rive_contract_test.dart"
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

Write-Host "Avatar V4 Pass 3C Rive asset contract applied."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
