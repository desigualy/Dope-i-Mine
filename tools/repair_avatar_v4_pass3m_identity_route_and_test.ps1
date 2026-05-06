$ErrorActionPreference = "Stop"

Write-Host "Repairing Avatar V4 Pass 3M identity route and over-patched tests..."

$voice = "lib\presentation\onboarding\voice_setup_screen.dart"
$flowTest = "test\onboarding\onboarding_flow_test.dart"
$router = "lib\app\router.dart"

if (!(Test-Path $voice)) { throw "Missing $voice. Run this from project root." }
if (!(Test-Path $flowTest)) { throw "Missing $flowTest. Run this from project root." }
if (!(Test-Path $router)) { throw "Missing $router. Run this from project root." }

# 1. Force voice setup to route to identity before avatar.
$voiceContent = Get-Content $voice -Raw
$voiceContent = $voiceContent.Replace("'/onboarding/avatar'", "'/onboarding/identity'")
$voiceContent = $voiceContent.Replace('"/onboarding/avatar"', '"/onboarding/identity"')
$voiceContent = $voiceContent.Replace("totalSteps: 12,", "totalSteps: 13,")
Set-Content -Path $voice -Value $voiceContent -NoNewline
Write-Host "Forced voice setup next route to /onboarding/identity."

# 2. Ensure router actually exposes /onboarding/identity.
$routerContent = Get-Content $router -Raw

if ($routerContent -notmatch "identity_screen\.dart") {
  $routerContent = $routerContent.Replace(
    "import '../presentation/onboarding/avatar_setup_screen.dart';",
    "import '../presentation/onboarding/avatar_setup_screen.dart';`r`nimport '../presentation/onboarding/identity_screen.dart';"
  )
  Write-Host "Added identity_screen import."
}

if ($routerContent -notmatch "path: '/onboarding/identity'") {
  $identityRoute = @"
    GoRoute(
      path: '/onboarding/identity',
      builder: (_, state) => IdentityScreen(
        returnToSummary: state.uri.queryParameters['return'] == 'summary',
      ),
    ),
"@

  $routerContent = $routerContent.Replace(
    "    GoRoute(`r`n      path: '/onboarding/avatar',",
    $identityRoute + "    GoRoute(`r`n      path: '/onboarding/avatar',"
  )
  $routerContent = $routerContent.Replace(
    "    GoRoute(`n      path: '/onboarding/avatar',",
    $identityRoute + "    GoRoute(`n      path: '/onboarding/avatar',"
  )
  Write-Host "Added /onboarding/identity route."
} else {
  Write-Host "/onboarding/identity route already present."
}

Set-Content -Path $router -Value $routerContent -NoNewline

# 3. The prior repair inserted identity expectations before every Avatar expectation.
# Remove that inserted identity block from the home-avatar-entry test only.
$content = Get-Content $flowTest -Raw

$testName = "home avatar entry opens Avatar Engine V4 customizer"
$start = $content.IndexOf($testName)
if ($start -ge 0) {
  $next = $content.IndexOf("testWidgets(", $start + $testName.Length)
  if ($next -lt 0) { $next = $content.Length }

  $before = $content.Substring(0, $start)
  $section = $content.Substring($start, $next - $start)
  $after = $content.Substring($next)

  $identityBlockPattern = "(?s)\s*expect\(find\.text\('Sex, gender & pronouns'\), findsOneWidget\);\s*expect\(\s*find\.byKey\(const ValueKey<String>\('onboarding-sex-at-birth-field'\)\),\s*findsOneWidget,\s*\);\s*expect\(\s*find\.byKey\(const ValueKey<String>\('onboarding-gender-identity-field'\)\),\s*findsOneWidget,\s*\);\s*expect\(\s*find\.byKey\(const ValueKey<String>\('onboarding-pronouns-field'\)\),\s*findsOneWidget,\s*\);\s*await tester\.tap\(find\.text\('Next'\)\);\s*await tester\.pumpAndSettle\(\);\s*"

  if ($section -match "Sex, gender & pronouns") {
    $section = [regex]::Replace($section, $identityBlockPattern, "`r`n    ")
    $content = $before + $section + $after
    Write-Host "Removed misplaced identity block from home-avatar-entry test."
  } else {
    Write-Host "Home-avatar-entry test was not over-patched."
  }
} else {
  Write-Host "Could not find home-avatar-entry test by name; skipped targeted cleanup."
}

# 4. Add a direct route smoke test for identity if absent.
if ($content -notmatch "direct identity route exposes sex gender pronouns fields") {
  $insert = @'

testWidgets('direct identity route exposes sex gender pronouns fields', (tester) async {
  await pumpApp(tester, initialLocation: '/onboarding/identity');

  expect(find.text('Sex, gender & pronouns'), findsOneWidget);
  expect(
    find.byKey(const ValueKey<String>('onboarding-sex-at-birth-field')),
    findsOneWidget,
  );
  expect(
    find.byKey(const ValueKey<String>('onboarding-gender-identity-field')),
    findsOneWidget,
  );
  expect(
    find.byKey(const ValueKey<String>('onboarding-pronouns-field')),
    findsOneWidget,
  );
});
'@

  $lastBrace = $content.LastIndexOf("}")
  if ($lastBrace -gt 0) {
    $content = $content.Insert($lastBrace, $insert + "`r`n")
    Write-Host "Added direct identity route smoke test."
  }
}

Set-Content -Path $flowTest -Value $content -NoNewline

Write-Host "Avatar V4 Pass 3M identity route/test repair complete."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
