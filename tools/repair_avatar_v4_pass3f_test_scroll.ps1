$ErrorActionPreference = "Stop"

Write-Host "Repairing Avatar V4 Pass 3F customizer test scroll issue..."

$file = "test\avatar_v4\avatar_v4_customizer_service_wiring_test.dart"

if (!(Test-Path $file)) {
  throw "Missing $file. Run this from the project root."
}

$content = Get-Content $file -Raw

$old = @'
    await tester.tap(
      find.byKey(const ValueKey<String>('avatar-v4-reference-consent')),
    );
    await tester.pump();

    button = tester.widget<FilledButton>(
'@

$new = @'
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('avatar-v4-reference-consent')),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('avatar-v4-reference-consent')),
    );
    await tester.pumpAndSettle();

    button = tester.widget<FilledButton>(
'@

if ($content.Contains($old)) {
  $content = $content.Replace($old, $new)
  Set-Content -Path $file -Value $content -NoNewline
  Write-Host "Patched customizer service wiring test to scroll before tapping consent."
} elseif ($content.Contains("scrollUntilVisible") -and $content.Contains("avatar-v4-reference-consent")) {
  Write-Host "Customizer service wiring test already has scroll-before-tap repair."
} else {
  throw "Could not find expected tap block in $file"
}

Write-Host "Avatar V4 Pass 3F test scroll repair complete."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
