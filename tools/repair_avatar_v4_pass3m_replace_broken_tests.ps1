$ErrorActionPreference = "Stop"

Write-Host "Replacing broken Pass 3M test files with corrected source-contract tests..."

$projectRoot = Get-Location
$patchRoot = Split-Path -Parent $PSScriptRoot

$files = @(
  "test\onboarding\onboarding_flow_test.dart",
  "test\avatar_v4\avatar_v4_onboarding_purge_test.dart"
)

foreach ($relative in $files) {
  $source = Join-Path $patchRoot $relative
  $target = Join-Path $projectRoot $relative

  if (!(Test-Path $source)) {
    throw "Missing patch file: $source"
  }

  if (Test-Path $target) {
    Copy-Item -Force $target "$target.bak_pass3m_broken_tests"
    Write-Host "Backed up $relative"
  }

  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
  Copy-Item -Force $source $target
  Write-Host "Replaced $relative"
}

Write-Host "Formatting replaced Dart test files..."
dart format test\onboarding\onboarding_flow_test.dart test\avatar_v4\avatar_v4_onboarding_purge_test.dart | Out-Host

Write-Host "Pass 3M broken-test replacement complete."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
