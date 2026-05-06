$ErrorActionPreference = "Stop"

Write-Host "Repairing login/onboarding test contract drift..."

$file = "test\onboarding\onboarding_flow_test.dart"

if (!(Test-Path $file)) {
  throw "Missing $file. Run this from the project root."
}

$content = Get-Content $file -Raw

$oldShortPassword = @'
    expect(find.text('Meet Dope-i'), findsOneWidget);
    expect(find.text('Password must be at least 8 characters.'), findsNothing);
'@

$newShortPassword = @'
    await _pumpUntilAbsent(
      tester,
      find.text('Password must be at least 8 characters.'),
    );
    expect(fakeAuthRepository.user, isNotNull);
    expect(find.text('Password must be at least 8 characters.'), findsNothing);
'@

$oldLookupFailure = @'
    expect(find.text('Meet Dope-i'), findsOneWidget);
    expect(find.text('Cannot read onboarding status'), findsNothing);
'@

$newLookupFailure = @'
    await _pumpUntilAbsent(
      tester,
      find.text('Cannot read onboarding status'),
    );
    expect(fakeAuthRepository.user, isNotNull);
    expect(find.text('Cannot read onboarding status'), findsNothing);
'@

$changed = $false

if ($content.Contains($oldShortPassword)) {
  $content = $content.Replace($oldShortPassword, $newShortPassword)
  $changed = $true
  Write-Host "Patched shorter-password login expectation."
} else {
  Write-Host "Shorter-password expectation already patched or not found."
}

if ($content.Contains($oldLookupFailure)) {
  $content = $content.Replace($oldLookupFailure, $newLookupFailure)
  $changed = $true
  Write-Host "Patched profile-lookup-failure login expectation."
} else {
  Write-Host "Profile-lookup-failure expectation already patched or not found."
}

if ($changed) {
  Set-Content -Path $file -Value $content -NoNewline
}

Write-Host "Login/onboarding test contract repair complete."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
