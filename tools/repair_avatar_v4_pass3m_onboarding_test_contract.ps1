$ErrorActionPreference = "Stop"

Write-Host "Repairing Avatar V4 Pass 3M onboarding test contract..."

$file = "test\onboarding\onboarding_flow_test.dart"

if (!(Test-Path $file)) {
  throw "Missing $file. Run this from the project root."
}

$content = Get-Content $file -Raw

# Onboarding now has 13 steps because Pass 3M inserted Sex/Gender/Pronouns before Avatar.
$content = $content.Replace("Step 10 of 12", "Step 10 of 13")
$content = $content.Replace("Step 11 of 12", "Step 11 of 13")
$content = $content.Replace("Step 12 of 12", "Step 12 of 13")
$content = $content.Replace("Step 13 of 12", "Step 13 of 13")

# Old onboarding avatar title was Companion & avatar. New V4-only screen title is Avatar.
$content = $content.Replace("Companion & avatar", "Avatar")

# Insert expectations for the new identity step where the old test jumps from voice setup to avatar.
if ($content -notmatch "Sex, gender & pronouns") {
  $marker = @'
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Avatar'), findsOneWidget);
'@

  $replacement = @'
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Sex, gender & pronouns'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('onboarding-sex-at-birth-field')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('onboarding-gender-identity-field')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('onboarding-pronouns-field')), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Avatar'), findsOneWidget);
'@

  if ($content.Contains($marker)) {
    $content = $content.Replace($marker, $replacement)
    Write-Host "Inserted identity-step expectations before Avatar."
  } else {
    Write-Host "Could not find exact voice-to-avatar marker; step text/title contract still patched."
  }
} else {
  Write-Host "Identity-step expectations already present."
}

Set-Content -Path $file -Value $content -NoNewline

Write-Host "Avatar V4 Pass 3M onboarding test contract repair complete."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
