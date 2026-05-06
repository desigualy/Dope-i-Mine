$ErrorActionPreference = "Stop"

$patchRoot = Split-Path -Parent $PSScriptRoot
$projectRoot = Get-Location

Write-Host "Applying Avatar V4 Pass 3H Rive asset handoff pack..."

$files = @(
  "docs\avatar_rive\AVATAR_V4_RIVE_ARTIST_BRIEF.md",
  "docs\avatar_rive\AVATAR_V4_RIVE_TECHNICAL_CONTRACT.md",
  "docs\avatar_rive\AVATAR_V4_STYLE_ACCEPTANCE_CHECKLIST.md",
  "assets\avatar_rive\base_avatar.README.md",
  "assets\avatar_rive\base_avatar_contract_checklist.json",
  "lib\avatar_engine_v4\domain\avatar_v4_asset_handoff.dart",
  "lib\avatar_engine_v4\avatar_engine_v4.dart",
  "test\avatar_v4\avatar_v4_asset_handoff_test.dart"
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

Write-Host "Avatar V4 Pass 3H Rive asset handoff pack applied."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
