$ErrorActionPreference = "Stop"

$patchRoot = Split-Path -Parent $PSScriptRoot
$projectRoot = Get-Location

Write-Host "Applying Avatar Engine V4 / Rive Pass 3A foundation..."

$files = @(
  "lib\avatar_engine_v4\avatar_engine_v4.dart",
  "lib\avatar_engine_v4\domain\avatar_engine_mode.dart",
  "lib\avatar_engine_v4\domain\avatar_v4_config.dart",
  "lib\avatar_engine_v4\domain\avatar_v4_inventory.dart",
  "lib\avatar_engine_v4\data\avatar_v4_local_cache.dart",
  "lib\avatar_engine_v4\data\avatar_v4_repository.dart",
  "lib\avatar_engine_v4\runtime\avatar_rive_asset_resolver.dart",
  "lib\avatar_engine_v4\runtime\avatar_rive_controller.dart",
  "lib\avatar_engine_v4\presentation\avatar_missing_rig_diagnostic.dart",
  "lib\avatar_engine_v4\presentation\avatar_rive_view.dart",
  "lib\avatar_engine_v4\presentation\avatar_customizer_screen.dart",
  "test\avatar_v4\avatar_v4_config_test.dart",
  "test\avatar_v4\avatar_v4_rive_view_test.dart"
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

if ($pubspec -notmatch "(?m)^\s{2}rive\s*:") {
  $pubspec = $pubspec -replace "(?m)^dependencies:\s*$", "dependencies:`r`n  rive: ^0.13.20"
  Set-Content -Path $pubspecPath -Value $pubspec -NoNewline
  Write-Host "Added rive dependency."
} else {
  Write-Host "rive dependency already present."
}

if ($pubspec -notmatch "assets/avatar_rive/") {
  $pubspec = Get-Content $pubspecPath -Raw
  if ($pubspec -match "(?m)^flutter:\s*$") {
    if ($pubspec -match "(?m)^\s{2}assets:\s*$") {
      $pubspec = $pubspec -replace "(?m)^(\s{2}assets:\s*)$", "`$1`r`n    - assets/avatar_rive/"
    } else {
      $pubspec = $pubspec -replace "(?m)^flutter:\s*$", "flutter:`r`n  assets:`r`n    - assets/avatar_rive/"
    }
  } else {
    $pubspec = $pubspec + "`r`n`r`nflutter:`r`n  assets:`r`n    - assets/avatar_rive/`r`n"
  }
  Set-Content -Path $pubspecPath -Value $pubspec -NoNewline
  Write-Host "Added assets/avatar_rive/ to pubspec."
} else {
  Write-Host "assets/avatar_rive/ already declared."
}

New-Item -ItemType Directory -Force -Path (Join-Path $projectRoot "assets\avatar_rive") | Out-Null
$keep = Join-Path $projectRoot "assets\avatar_rive\.gitkeep"
if (!(Test-Path $keep)) {
  Set-Content -Path $keep -Value "" -NoNewline
  Write-Host "Created assets\avatar_rive\.gitkeep"
}

Write-Host "Avatar Engine V4 / Rive Pass 3A foundation applied."
Write-Host "Run:"
Write-Host "  flutter pub get"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
