$ErrorActionPreference = "Stop"

$patchRoot = Split-Path -Parent $PSScriptRoot
$projectRoot = Get-Location

$copyRoots = @(
  "lib/domain/avatar_v3",
  "lib/data/local",
  "lib/data/repositories",
  "lib/presentation/avatar_v3",
  "lib/presentation/avatar",
  "lib/presentation/user_avatar",
  "assets/avatar_v3",
  "supabase/sql",
  "test/avatar_v3",
  "docs"
)

foreach ($root in $copyRoots) {
  $source = Join-Path $patchRoot $root
  if (Test-Path $source) {
    Get-ChildItem $source -Recurse -File | ForEach-Object {
      $relative = $_.FullName.Substring($patchRoot.Length + 1)
      $target = Join-Path $projectRoot $relative
      New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
      Copy-Item -Force $_.FullName $target
      Write-Host "Installed $relative"
    }
  }
}

# Remove obsolete visible painter files that should not remain active.
$obsolete = @(
  "lib/presentation/avatar_v2"
)

foreach ($path in $obsolete) {
  if (Test-Path $path) {
    Remove-Item -Recurse -Force $path
    Write-Host "Deleted obsolete renderer path $path"
  }
}

# Ensure pubspec has SVG rendering dependency and Avatar V3 asset folder.
$pubspec = "pubspec.yaml"
$content = Get-Content $pubspec -Raw

if ($content -notmatch "flutter_svg:") {
  $content = $content -replace "(  image_picker: [^\r\n]+)", "`$1`n  flutter_svg: ^2.0.17`n  vector_graphics: ^1.1.15"
  Write-Host "Added flutter_svg/vector_graphics dependencies."
}

if ($content -notmatch "assets/avatar_v3/") {
  $content = $content -replace "(    - assets/app_store/\r?\n)", "`$1    - assets/avatar_v3/`n"
  Write-Host "Added assets/avatar_v3/ to pubspec assets."
}

Set-Content -Path $pubspec -Value $content -NoNewline

Write-Host "Avatar V3 Pass 1 foundation applied."
