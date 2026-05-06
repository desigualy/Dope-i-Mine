$ErrorActionPreference = "Stop"

Write-Host "Applying PASS 3M STOP-LOOP solution..."

$flowTest = "test\onboarding\onboarding_flow_test.dart"
$purgeTest = "test\avatar_v4\avatar_v4_onboarding_purge_test.dart"
$summary = "lib\presentation\onboarding\onboarding_summary_screen.dart"
$identity = "lib\presentation\onboarding\identity_screen.dart"
$router = "lib\app\router.dart"
$voice = "lib\presentation\onboarding\voice_setup_screen.dart"
$avatar = "lib\presentation\onboarding\avatar_setup_screen.dart"
$stateFile = "lib\domain\onboarding\onboarding_state.dart"
$repoFile = "lib\data\repositories\profile_repository_impl.dart"

foreach ($path in @($flowTest, $purgeTest, $summary, $identity, $router, $voice, $avatar, $stateFile, $repoFile)) {
  if (!(Test-Path $path)) {
    throw "Missing required file: $path"
  }
}

# ---------------------------------------------------------------------------
# 1. Fix onboarding_flow_test.dart compile failure:
#    IdentityScreen is used in helper routers, but the import is missing.
# ---------------------------------------------------------------------------
$flow = Get-Content $flowTest -Raw

if ($flow -notmatch "presentation/onboarding/identity_screen\.dart") {
  $anchor = "import 'package:dope_i_mine/presentation/onboarding/avatar_setup_screen.dart';"
  if ($flow.Contains($anchor)) {
    $flow = $flow.Replace(
      $anchor,
      $anchor + "`r`nimport 'package:dope_i_mine/presentation/onboarding/identity_screen.dart';"
    )
    Write-Host "Added IdentityScreen import to onboarding_flow_test.dart."
  } else {
    $flow = "import 'package:dope_i_mine/presentation/onboarding/identity_screen.dart';`r`n" + $flow
    Write-Host "Inserted IdentityScreen import at top of onboarding_flow_test.dart."
  }
}

# Silence the helper warning if the file still contains a source-contract-only helper.
if ($flow -match "GoRouter _buildOnboardingRouter" -and $flow -notmatch "ignore: unused_element\s*`r?`n\s*GoRouter _buildOnboardingRouter") {
  $flow = $flow.Replace(
    "GoRouter _buildOnboardingRouter",
    "// ignore: unused_element`r`nGoRouter _buildOnboardingRouter"
  )
  Write-Host "Silenced unused _buildOnboardingRouter warning."
}

Set-Content -Path $flowTest -Value $flow -NoNewline

# ---------------------------------------------------------------------------
# 2. Fix onboarding_summary_screen.dart properly.
#    Previous PowerShell interpolation produced blank identity values:
#      Sex at birth:  · Gender:  · Pronouns:
#    This writes the actual Dart expression into the file.
# ---------------------------------------------------------------------------
$summaryContent = Get-Content $summary -Raw

if ($summaryContent -notmatch "domain/onboarding/onboarding_state\.dart") {
  $summaryContent = $summaryContent.Replace(
    "import '../../domain/companion/avatar_config_model.dart';",
    "import '../../domain/companion/avatar_config_model.dart';`r`nimport '../../domain/onboarding/onboarding_state.dart';"
  )
  Write-Host "Added onboarding_state import to summary screen."
}

$fixedIdentityRow = @'
            _summaryRow(
              label: 'Sex, gender & pronouns',
              value:
                  'Sex at birth: ${state.sexAtBirth.label} · Gender: ${state.genderIdentity.label} · Pronouns: ${state.pronounDisplay}',
              onEdit: () => context.go('/onboarding/identity?return=summary'),
            ),
'@

# Replace any existing Sex/Gender/Pronouns summary row, damaged or otherwise.
$identityRowPattern = "(?s)\s*_summaryRow\(\s*label:\s*'Sex, gender & pronouns',\s*value:\s*(?:'[^']*'|[\s\S]*?Pronouns:[\s\S]*?'),\s*onEdit:\s*\(\)\s*=>\s*context\.go\('/onboarding/identity\?return=summary'\),\s*\),"

if ([regex]::IsMatch($summaryContent, $identityRowPattern)) {
  $summaryContent = [regex]::Replace($summaryContent, $identityRowPattern, "`r`n" + $fixedIdentityRow, 1)
  Write-Host "Replaced existing identity summary row with real state-backed row."
} elseif ($summaryContent -notmatch "state\.pronounDisplay") {
  # Insert after Assistant name row if no identity row exists.
  $assistantRowEnd = "context.go('/onboarding/assistant-name?return=summary'),"
  $idx = $summaryContent.IndexOf($assistantRowEnd)
  if ($idx -ge 0) {
    $closeIdx = $summaryContent.IndexOf("),", $idx)
    if ($closeIdx -ge 0) {
      $insertAt = $closeIdx + 2
      $summaryContent = $summaryContent.Insert($insertAt, "`r`n" + $fixedIdentityRow)
      Write-Host "Inserted missing identity summary row."
    }
  }
}

# Repair CRLF escape contamination from earlier scripts.
$summaryContent = $summaryContent.Replace("\r\n", "`r`n")
$summaryContent = $summaryContent.Replace("            ),            _summaryRow(", "            ),`r`n            _summaryRow(")

Set-Content -Path $summary -Value $summaryContent -NoNewline

# ---------------------------------------------------------------------------
# 3. Replace avatar_v4_onboarding_purge_test.dart completely.
#    This is intentional. That file is corrupted and still expects:
#      path: /onboarding/identity
#    which can never be valid Dart source.
# ---------------------------------------------------------------------------
$purgeReplacement = @'
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('onboarding avatar setup is Avatar V4 only', () {
    final file = File('lib/presentation/onboarding/avatar_setup_screen.dart');
    expect(file.existsSync(), isTrue);

    final content = file.readAsStringSync();

    expect(content, contains('AvatarRiveView'));
    expect(content, contains('AvatarV4Config'));
    expect(content, contains('onboarding-avatar-preview'));

    expect(content, isNot(contains('AvatarCreatorScreen')));
    expect(content, isNot(contains('AvatarCandidateSelectorScreen')));
    expect(content, isNot(contains('AvatarPreviewCard')));
    expect(content, isNot(contains('currentUserAvatarConfigProvider')));
    expect(content, isNot(contains('domain/avatar/user_avatar_profile.dart')));
    expect(content, isNot(contains('data/avatar/')));
  });

  test('voice setup routes to identity before avatar', () {
    final file = File('lib/presentation/onboarding/voice_setup_screen.dart');
    expect(file.existsSync(), isTrue);

    final content = file.readAsStringSync();

    expect(content, contains('/onboarding/identity'));
    expect(content, isNot(contains("'/onboarding/avatar'")));
    expect(content, isNot(contains('"/onboarding/avatar"')));
  });

  test('router exposes identity onboarding route', () {
    final file = File('lib/app/router.dart');
    expect(file.existsSync(), isTrue);

    final content = file.readAsStringSync();

    expect(content, contains('identity_screen.dart'));
    expect(content, contains('/onboarding/identity'));
    expect(content, contains('IdentityScreen'));
  });

  test('identity screen exposes sex gender pronouns fields and routes onward', () {
    final file = File('lib/presentation/onboarding/identity_screen.dart');
    expect(file.existsSync(), isTrue);

    final content = file.readAsStringSync();

    expect(content, contains('Sex, gender & pronouns'));
    expect(content, contains('onboarding-sex-at-birth-field'));
    expect(content, contains('onboarding-gender-identity-field'));
    expect(content, contains('onboarding-pronouns-field'));
    expect(content, contains('/onboarding/avatar'));
  });

  test('summary and repository persist identity fields', () {
    final summary = File('lib/presentation/onboarding/onboarding_summary_screen.dart')
        .readAsStringSync();
    final repository =
        File('lib/data/repositories/profile_repository_impl.dart').readAsStringSync();
    final state = File('lib/domain/onboarding/onboarding_state.dart').readAsStringSync();

    expect(summary, contains('Sex, gender & pronouns'));
    expect(summary, contains('state.sexAtBirth.label'));
    expect(summary, contains('state.genderIdentity.label'));
    expect(summary, contains('state.pronounDisplay'));
    expect(summary, contains('/onboarding/identity?return=summary'));

    expect(repository, contains('sex_at_birth'));
    expect(repository, contains('gender_identity'));
    expect(repository, contains('pronouns'));
    expect(repository, contains('custom_pronouns'));

    expect(state, contains('enum SexAtBirth'));
    expect(state, contains('enum GenderIdentity'));
    expect(state, contains('enum PronounSet'));
    expect(state, contains('String get pronounDisplay'));
  });
}
'@

Set-Content -Path $purgeTest -Value $purgeReplacement -NoNewline
Write-Host "Replaced corrupted avatar_v4_onboarding_purge_test.dart."

# ---------------------------------------------------------------------------
# 4. Lock the real app route again in case older scripts reverted it.
# ---------------------------------------------------------------------------
$voiceContent = Get-Content $voice -Raw
$voiceContent = $voiceContent.Replace("'/onboarding/avatar'", "'/onboarding/identity'")
$voiceContent = $voiceContent.Replace('"/onboarding/avatar"', '"/onboarding/identity"')
Set-Content -Path $voice -Value $voiceContent -NoNewline

$routerContent = Get-Content $router -Raw
if ($routerContent -notmatch "identity_screen\.dart") {
  $routerContent = $routerContent.Replace(
    "import '../presentation/onboarding/avatar_setup_screen.dart';",
    "import '../presentation/onboarding/avatar_setup_screen.dart';`r`nimport '../presentation/onboarding/identity_screen.dart';"
  )
}

if ($routerContent -notmatch "path:\s*'/onboarding/identity'") {
  $identityRoute = @'
    GoRoute(
      path: '/onboarding/identity',
      builder: (_, state) => IdentityScreen(
        returnToSummary: state.uri.queryParameters['return'] == 'summary',
      ),
    ),
'@
  $routerContent = [regex]::Replace(
    $routerContent,
    "(\s*GoRoute\(\s*path:\s*'/onboarding/avatar',)",
    "`r`n" + $identityRoute + '$1',
    1
  )
}

Set-Content -Path $router -Value $routerContent -NoNewline

# ---------------------------------------------------------------------------
# 5. Format touched Dart files.
# ---------------------------------------------------------------------------
dart format $flowTest $purgeTest $summary $voice $router | Out-Host

Write-Host "PASS 3M STOP-LOOP solution complete."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
