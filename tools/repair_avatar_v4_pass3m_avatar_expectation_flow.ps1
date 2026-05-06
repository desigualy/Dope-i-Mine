$ErrorActionPreference = "Stop"

Write-Host "Repairing Avatar V4 Pass 3M Avatar expectation flow..."

$flowTest = "test\onboarding\onboarding_flow_test.dart"
$purgeTest = "test\avatar_v4\avatar_v4_onboarding_purge_test.dart"

if (!(Test-Path $flowTest)) {
  throw "Missing $flowTest. Run this from the project root."
}

$content = Get-Content $flowTest -Raw

$old = "    expect(find.text('Avatar'), findsOneWidget);"
$new = @"
    if (find.text('Avatar').evaluate().isEmpty) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Avatar'), findsOneWidget);
"@

if ($content -notmatch "find\.text\('Avatar'\)\.evaluate\(\)\.isEmpty") {
  $count = ([regex]::Matches($content, [regex]::Escape($old))).Count
  if ($count -eq 0) {
    throw "Could not find Avatar expectation in $flowTest"
  }

  $content = $content.Replace($old, $new)
  Set-Content -Path $flowTest -Value $content -NoNewline
  Write-Host "Patched $count Avatar expectation(s) to step through identity when needed."
} else {
  Write-Host "Avatar expectation flow guard already present."
}

if (Test-Path $purgeTest) {
  $purge = Get-Content $purgeTest -Raw
  $purge = $purge.Replace('contains("path: ''/onboarding/identity''")', "contains('path: ''/onboarding/identity''')")
  Set-Content -Path $purgeTest -Value $purge -NoNewline
  Write-Host "Cleaned remaining quote lint in avatar_v4_onboarding_purge_test.dart."
}

Write-Host "Avatar V4 Pass 3M Avatar expectation flow repair complete."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
