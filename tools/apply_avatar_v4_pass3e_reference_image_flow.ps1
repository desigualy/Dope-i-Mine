$ErrorActionPreference = "Stop"

$patchRoot = Split-Path -Parent $PSScriptRoot
$projectRoot = Get-Location

Write-Host "Applying Avatar V4 Pass 3E reference-image upload flow..."

$files = @(
  "lib\avatar_engine_v4\domain\avatar_v4_reference_image_upload.dart",
  "lib\avatar_engine_v4\data\avatar_v4_reference_image_storage.dart",
  "lib\avatar_engine_v4\data\avatar_v4_reference_image_service.dart",
  "lib\avatar_engine_v4\presentation\avatar_reference_image_panel.dart",
  "lib\avatar_engine_v4\presentation\avatar_customizer_screen.dart",
  "lib\avatar_engine_v4\avatar_engine_v4.dart",
  "supabase\migrations\202605060002_avatar_reference_storage.sql",
  "test\avatar_v4\avatar_v4_reference_image_service_test.dart",
  "test\avatar_v4\avatar_v4_reference_image_panel_test.dart"
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

$pubspecPath = Join-Path $projectRoot "pubspec.yaml"
if (!(Test-Path $pubspecPath)) {
  throw "pubspec.yaml not found."
}

$pubspec = Get-Content $pubspecPath -Raw

if ($pubspec -notmatch "(?m)^\s{2}image_picker\s*:") {
  $pubspec = $pubspec -replace "(?m)^dependencies:\s*$", "dependencies:`r`n  image_picker: ^1.1.2"
  Set-Content -Path $pubspecPath -Value $pubspec -NoNewline
  Write-Host "Added image_picker dependency."
} else {
  Write-Host "image_picker dependency already present."
}

Write-Host "Avatar V4 Pass 3E reference-image upload flow applied."
Write-Host "Run:"
Write-Host "  flutter pub get"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
Write-Host "Manual Supabase SQL Editor:"
Write-Host "  supabase\migrations\202605060002_avatar_reference_storage.sql"
