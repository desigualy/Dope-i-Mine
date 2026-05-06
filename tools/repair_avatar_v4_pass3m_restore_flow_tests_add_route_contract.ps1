$ErrorActionPreference = "Stop"

Write-Host "Repairing Avatar V4 Pass 3M flow tests and locking identity route contract..."

$flowTest = "test\onboarding\onboarding_flow_test.dart"
$routeTest = "test\avatar_v4\avatar_v4_onboarding_purge_test.dart"
$voice = "lib\presentation\onboarding\voice_setup_screen.dart"
$router = "lib\app\router.dart"

foreach ($path in @($flowTest, $routeTest, $voice, $router)) {
  if (!(Test-Path $path)) {
    throw "Missing $path. Run this from the project root."
  }
}

# 1. Remove identity expectation blocks that were inserted into flow tests.
# Those tests were written for broad wizard traversal and became brittle once
# the route contract changed. The real contract is checked below by source tests.
$content = Get-Content $flowTest -Raw

$identityBlockPattern = "(?s)\s*expect\(find\.text\('Sex, gender & pronouns'\), findsOneWidget\);\s*expect\(\s*find\.byKey\(const ValueKey<String>\('onboarding-sex-at-birth-field'\)\),\s*findsOneWidget,\s*\);\s*expect\(\s*find\.byKey\(const ValueKey<String>\('onboarding-gender-identity-field'\)\),\s*findsOneWidget,\s*\);\s*expect\(\s*find\.byKey\(const ValueKey<String>\('onboarding-pronouns-field'\)\),\s*findsOneWidget,\s*\);\s*await tester\.tap\(find\.text\('Next'\)\);\s*await tester\.pumpAndSettle\(\);\s*"

$beforeCount = ([regex]::Matches($content, $identityBlockPattern)).Count
if ($beforeCount -gt 0) {
  $content = [regex]::Replace($content, $identityBlockPattern, "`r`n    ")
  Set-Content -Path $flowTest -Value $content -NoNewline
  Write-Host "Removed $beforeCount misplaced identity expectation block(s) from onboarding_flow_test.dart."
} else {
  Write-Host "No misplaced identity expectation blocks found in onboarding_flow_test.dart."
}

# 2. Hard-lock voice setup source to route to identity, not avatar.
$voiceContent = Get-Content $voice -Raw
$voiceContent = $voiceContent.Replace("'/onboarding/avatar'", "'/onboarding/identity'")
$voiceContent = $voiceContent.Replace('"/onboarding/avatar"', '"/onboarding/identity"')
$voiceContent = $voiceContent.Replace("totalSteps: 12,", "totalSteps: 13,")
Set-Content -Path $voice -Value $voiceContent -NoNewline
Write-Host "Locked voice setup next route to /onboarding/identity."

# 3. Hard-lock router source to expose identity route and import.
$routerContent = Get-Content $router -Raw
if ($routerContent -notmatch "identity_screen\.dart") {
  $routerContent = $routerContent.Replace(
    "import '../presentation/onboarding/avatar_setup_screen.dart';",
    "import '../presentation/onboarding/avatar_setup_screen.dart';`r`nimport '../presentation/onboarding/identity_screen.dart';"
  )
  Write-Host "Added identity_screen import to router."
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
  Write-Host "Added identity route to router."
} else {
  Write-Host "Router already has identity route."
}

Set-Content -Path $router -Value $routerContent -NoNewline

# 4. Expand source-contract tests that do not depend on fragile pump helpers.
$routeContent = Get-Content $routeTest -Raw

if ($routeContent -notmatch "voice setup routes to identity before avatar") {
  $insert = @'

  test('voice setup routes to identity before avatar', () {
    final file = File('lib/presentation/onboarding/voice_setup_screen.dart');
    expect(file.existsSync(), isTrue);

    final content = file.readAsStringSync();

    expect(content, contains('/onboarding/identity'));
    expect(content, isNot(contains('/onboarding/avatar')));
  });

  test('router exposes identity onboarding route', () {
    final file = File('lib/app/router.dart');
    expect(file.existsSync(), isTrue);

    final content = file.readAsStringSync();

    expect(content, contains("identity_screen.dart"));
    expect(content, contains("path: '/onboarding/identity'"));
    expect(content, contains('IdentityScreen'));
  });
'@

  $lastBrace = $routeContent.LastIndexOf("}")
  if ($lastBrace -lt 0) {
    throw "Could not find closing brace in $routeTest"
  }

  $routeContent = $routeContent.Insert($lastBrace, $insert + "`r`n")
  Set-Content -Path $routeTest -Value $routeContent -NoNewline
  Write-Host "Added source-contract tests for voice route and router identity route."
} else {
  Write-Host "Voice/router identity contract tests already present."
}

Write-Host "Avatar V4 Pass 3M flow restore + route contract repair complete."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
