$ErrorActionPreference = "Stop"

$patchRoot = Split-Path -Parent $PSScriptRoot
$projectRoot = Get-Location

Write-Host "Applying Avatar V4 Pass 3I Rive handoff pack..."

$files = @(
  "docs\avatar_v4\AVATAR_V4_RIVE_HANDOFF_SPEC.md",
  "docs\avatar_v4\AVATAR_V4_RIVE_INPUT_MAP.md",
  "docs\avatar_v4\AVATAR_V4_LAYER_NAMING_CONTRACT.md",
  "docs\avatar_v4\AVATAR_V4_QA_CHECKLIST.md",
  "docs\avatar_v4\AVATAR_V4_ARTIST_BRIEF.md",
  "assets\avatar_rive\base_avatar.riv.README_PLACEHOLDER.txt",
  "assets\avatar_rive\avatar_v4_rive_handoff.json",
  "test\avatar_v4\avatar_v4_rive_handoff_pack_test.dart"
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

Write-Host "Avatar V4 Pass 3I Rive handoff pack applied."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
