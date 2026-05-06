$ErrorActionPreference = "Stop"

Write-Host "Repairing Avatar V4 Pass 3M bad pumpApp test insertion..."

$file = "test\onboarding\onboarding_flow_test.dart"

if (!(Test-Path $file)) {
  throw "Missing $file. Run this from the project root."
}

$content = Get-Content $file -Raw

# Remove the direct identity route smoke test inserted by the prior repair.
# This repo's onboarding_flow_test.dart does not define pumpApp(), so the added
# test is invalid in this file. The identity route is already guarded by the
# main flow tests and avatar_v4_onboarding_purge_test.dart.
$pattern = "(?s)\s*testWidgets\('direct identity route exposes sex gender pronouns fields', \(tester\) async \{\s*await pumpApp\(tester, initialLocation: '/onboarding/identity'\);\s*expect\(find\.text\('Sex, gender & pronouns'\), findsOneWidget\);\s*expect\(\s*find\.byKey\(const ValueKey<String>\('onboarding-sex-at-birth-field'\)\),\s*findsOneWidget,\s*\);\s*expect\(\s*find\.byKey\(const ValueKey<String>\('onboarding-gender-identity-field'\)\),\s*findsOneWidget,\s*\);\s*expect\(\s*find\.byKey\(const ValueKey<String>\('onboarding-pronouns-field'\)\),\s*findsOneWidget,\s*\);\s*\}\);\s*"

if ($content -match "direct identity route exposes sex gender pronouns fields") {
  $content = [regex]::Replace($content, $pattern, "`r`n")
  Set-Content -Path $file -Value $content -NoNewline
  Write-Host "Removed invalid pumpApp identity route smoke test."
} else {
  Write-Host "Invalid pumpApp test was already removed."
}

Write-Host "Avatar V4 Pass 3M bad pumpApp test repair complete."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
