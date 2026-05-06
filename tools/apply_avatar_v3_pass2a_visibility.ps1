$ErrorActionPreference = "Stop"

$patchRoot = Split-Path -Parent $PSScriptRoot
$projectRoot = Get-Location

$files = @(
  "lib\presentation\avatar_v3\avatar_v3_inline_assets.dart",
  "lib\presentation\avatar_v3\avatar_v3_layer_stack.dart",
  "lib\presentation\avatar_v3\avatar_v3_renderer.dart",
  "lib\presentation\avatar\avatar_engine_bridge.dart",
  "test\avatar_v3\avatar_v3_visibility_test.dart"
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

Write-Host "Avatar V3 Pass 2A visibility hard-fix applied."
