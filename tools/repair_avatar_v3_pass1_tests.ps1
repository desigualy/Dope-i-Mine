$ErrorActionPreference = "Stop"

$patchRoot = Split-Path -Parent $PSScriptRoot
$projectRoot = Get-Location

$source = Join-Path $patchRoot "test\user_avatar\user_avatar_renderer_test.dart"
$target = Join-Path $projectRoot "test\user_avatar\user_avatar_renderer_test.dart"

if (!(Test-Path $source)) {
  throw "Missing patch file: $source"
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
Copy-Item -Force $source $target

Write-Host "Replaced legacy user_avatar_renderer_test with Avatar V3 renderer assertions."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
