$ErrorActionPreference = "Stop"

$patchRoot = Split-Path -Parent $PSScriptRoot
$projectRoot = Get-Location

$files = @(
  "lib/domain/avatar_v3/avatar_v3_migration.dart"
)

foreach ($relative in $files) {
  $source = Join-Path $patchRoot $relative
  $target = Join-Path $projectRoot $relative
  if (!(Test-Path $source)) {
    throw "Missing patch file: $source"
  }
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
  Copy-Item -Force $source $target
  Write-Host "Patched $relative"
}

$pubspec = "pubspec.yaml"
$content = Get-Content $pubspec -Raw

if ($content -notmatch "(?m)^  flutter_svg:") {
  $content = $content -replace "(?m)^dependencies:\s*$", "dependencies:`n  flutter_svg: ^2.0.17"
  Write-Host "Added flutter_svg dependency."
}

if ($content -notmatch "(?m)^  vector_graphics:") {
  $content = $content -replace "(?m)^dependencies:\s*$", "dependencies:`n  vector_graphics: ^1.1.15"
  Write-Host "Added vector_graphics dependency."
}

if ($content -notmatch "assets/avatar_v3/") {
  $content = $content -replace "(?m)^  assets:\s*$", "  assets:`n    - assets/avatar_v3/"
  Write-Host "Added assets/avatar_v3/ asset folder."
}

Set-Content -Path $pubspec -Value $content -NoNewline

Write-Host "Avatar V3 Pass 1 compile repair complete."
