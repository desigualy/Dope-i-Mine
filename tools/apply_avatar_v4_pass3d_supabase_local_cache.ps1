$ErrorActionPreference = "Stop"

$patchRoot = Split-Path -Parent $PSScriptRoot
$projectRoot = Get-Location

Write-Host "Applying Avatar V4 Pass 3D Supabase/local-cache ownership wiring..."

$files = @(
  "lib\avatar_engine_v4\domain\avatar_v4_sync_failure.dart",
  "lib\avatar_engine_v4\data\avatar_v4_supabase_repository.dart",
  "lib\avatar_engine_v4\data\avatar_v4_sync_service.dart",
  "lib\avatar_engine_v4\avatar_engine_v4.dart",
  "supabase\migrations\202605060001_avatar_engine_v4.sql",
  "test\avatar_v4\avatar_v4_sync_service_test.dart",
  "test\avatar_v4\avatar_v4_supabase_contract_test.dart"
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

Write-Host "Avatar V4 Pass 3D Supabase/local-cache ownership wiring applied."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
Write-Host "Optional Supabase migration:"
Write-Host "  npx supabase db push"
