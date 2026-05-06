$ErrorActionPreference = "Stop"

$patchRoot = Split-Path -Parent $PSScriptRoot
$projectRoot = Get-Location

Write-Host "Applying Avatar V4 Pass 3J Rive asset acquisition/build workflow..."

$files = @(
  "docs\avatar_v4\AVATAR_V4_BASE_RIVE_BUILD_WORKFLOW.md",
  "docs\avatar_v4\AVATAR_V4_RIVE_ARTIST_DELIVERY_CHECKLIST.md",
  "docs\avatar_v4\AVATAR_V4_RIVE_IMPORT_QA_RUNBOOK.md",
  "assets\avatar_rive\base_avatar_import_manifest.json",
  "tools\import_avatar_v4_base_rive.ps1",
  "tools\verify_avatar_v4_base_rive.ps1",
  "test\avatar_v4\avatar_v4_base_rive_workflow_test.dart"
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

Write-Host "Avatar V4 Pass 3J Rive asset workflow applied."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
Write-Host ""
Write-Host "When you have base_avatar.riv:"
Write-Host "  .\tools\import_avatar_v4_base_rive.ps1 -SourcePath `"C:\path\to\base_avatar.riv`""
Write-Host "  .\tools\verify_avatar_v4_base_rive.ps1"
