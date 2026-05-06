$ErrorActionPreference = "Stop"

$patchRoot = Split-Path -Parent $PSScriptRoot
$projectRoot = Get-Location

Write-Host "Applying Avatar V4 Pass 3B home wiring..."

$files = @(
  "lib\presentation\home\home_screen.dart",
  "lib\presentation\user_avatar\user_avatar_studio.dart",
  "test\avatar_v4\avatar_v4_home_wiring_test.dart"
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

$router = "lib\app\router.dart"
if (Test-Path $router) {
  $content = Get-Content $router -Raw

  if ($content -notmatch "avatar_customizer_screen\.dart") {
    $content = $content -replace "import '../presentation/auth/signup_screen.dart';", "import '../presentation/auth/signup_screen.dart';`r`nimport '../avatar_engine_v4/presentation/avatar_customizer_screen.dart';"
    Write-Host "Added AvatarCustomizerScreen import."
  }

  if ($content -notmatch "path: '/avatar/customize'") {
    $route = @"
    GoRoute(
      path: '/avatar/customize',
      builder: (_, __) => const AvatarCustomizerScreen(),
    ),
"@
    $content = $content -replace "(    GoRoute\(path: '/settings', builder: \(_, __\) => const SettingsScreen\(\)\),)", "$route`r`n`$1"
    Write-Host "Added /avatar/customize route."
  }

  Set-Content -Path $router -Value $content -NoNewline
}

Write-Host "Avatar V4 Pass 3B home wiring applied."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
Write-Host "  flutter run"
