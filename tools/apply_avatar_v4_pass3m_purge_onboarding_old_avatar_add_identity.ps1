$ErrorActionPreference = "Stop"

$patchRoot = Split-Path -Parent $PSScriptRoot
$projectRoot = Get-Location

Write-Host "Applying Avatar V4 Pass 3M onboarding purge + identity section..."

$files = @(
  "lib\domain\onboarding\onboarding_state.dart",
  "lib\presentation\onboarding\onboarding_controller.dart",
  "lib\presentation\onboarding\identity_screen.dart",
  "lib\presentation\onboarding\avatar_setup_screen.dart",
  "supabase\migrations\202605060003_profile_identity_fields.sql",
  "test\avatar_v4\avatar_v4_onboarding_purge_test.dart"
)

foreach ($relative in $files) {
  $source = Join-Path $patchRoot $relative
  $target = Join-Path $projectRoot $relative

  if (!(Test-Path $source)) {
    throw "Missing patch file: $source"
  }

  $sourceResolved = (Resolve-Path $source).Path
  $targetResolved = if (Test-Path $target) { (Resolve-Path $target).Path } else { $target }

  if ($sourceResolved -ne $targetResolved) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
    Copy-Item -Force $source $target
    Write-Host "Patched $relative"
  } else {
    Write-Host "Already patched $relative"
  }
}

# Patch router import and route.
$router = "lib\app\router.dart"
if (Test-Path $router) {
  $routerContent = Get-Content $router -Raw

  if ($routerContent -notmatch "identity_screen\.dart") {
    $routerContent = $routerContent.Replace(
      "import '../presentation/onboarding/avatar_setup_screen.dart';",
      "import '../presentation/onboarding/avatar_setup_screen.dart';`r`nimport '../presentation/onboarding/identity_screen.dart';"
    )
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
  }

  if ($routerContent -notmatch "path: '/avatar/customize'") {
    if ($routerContent -notmatch "avatar_engine_v4/avatar_engine_v4\.dart") {
      $routerContent = $routerContent.Replace(
        "import '../presentation/auth/signup_screen.dart';",
        "import '../presentation/auth/signup_screen.dart';`r`nimport '../avatar_engine_v4/avatar_engine_v4.dart';"
      )
    }

    $customizerRoute = @"
    GoRoute(
      path: '/avatar/customize',
      builder: (_, __) => const AvatarCustomizerScreen(),
    ),
"@
    $routerContent = $routerContent.Replace(
      "    GoRoute(path: '/tasks/new',",
      $customizerRoute + "    GoRoute(path: '/tasks/new',"
    )
  }

  Set-Content -Path $router -Value $routerContent -NoNewline
  Write-Host "Patched router onboarding identity/avatar customizer routes."
} else {
  throw "Missing lib\app\router.dart"
}

# Patch voice setup to route into identity before avatar.
$voice = "lib\presentation\onboarding\voice_setup_screen.dart"
if (Test-Path $voice) {
  $voiceContent = Get-Content $voice -Raw
  $voiceContent = $voiceContent.Replace("totalSteps: 12,", "totalSteps: 13,")
  $voiceContent = $voiceContent.Replace(
    "widget.returnToSummary ? '/onboarding/summary' : '/onboarding/avatar'",
    "widget.returnToSummary ? '/onboarding/summary' : '/onboarding/identity'"
  )
  Set-Content -Path $voice -Value $voiceContent -NoNewline
  Write-Host "Patched voice setup to route to identity."
}

# Patch summary step count, rows, back path remains avatar.
$summary = "lib\presentation\onboarding\onboarding_summary_screen.dart"
if (Test-Path $summary) {
  $summaryContent = Get-Content $summary -Raw
  $summaryContent = $summaryContent.Replace("static const int _totalSteps = 12;", "static const int _totalSteps = 13;")

  if ($summaryContent -notmatch "label: 'Sex, gender & pronouns'") {
    $needle = @"
            _summaryRow(
              label: 'Assistant name',
              value: state.assistantDisplayName,
              onEdit: () =>
                  context.go('/onboarding/assistant-name?return=summary'),
            ),
"@
    $insert = $needle + @"
            _summaryRow(
              label: 'Sex, gender & pronouns',
              value:
                  'Sex at birth: ${state.sexAtBirth.label} · Gender: ${state.genderIdentity.label} · Pronouns: ${state.pronounDisplay}',
              onEdit: () => context.go('/onboarding/identity?return=summary'),
            ),
"@
    $summaryContent = $summaryContent.Replace($needle, $insert)
  }

  if ($summaryContent -notmatch "sexAtBirth: state.sexAtBirth.name") {
    $summaryContent = $summaryContent.Replace(
      "voiceEnabled: state.voiceEnabled,",
      "voiceEnabled: state.voiceEnabled,`r`n                            sexAtBirth: state.sexAtBirth.name,`r`n                            genderIdentity: state.genderIdentity.name,`r`n                            pronouns: state.pronouns.name,`r`n                            customPronouns: state.customPronouns,"
    )
  }

  Set-Content -Path $summary -Value $summaryContent -NoNewline
  Write-Host "Patched onboarding summary identity row and save payload."
}

# Patch profile repository to accept and persist optional identity fields.
$profileRepo = "lib\data\repositories\profile_repository_impl.dart"
if (Test-Path $profileRepo) {
  $repoContent = Get-Content $profileRepo -Raw

  if ($repoContent -notmatch "String\? sexAtBirth") {
    $repoContent = $repoContent.Replace(
      "bool reduceSurprises = true,",
      "bool reduceSurprises = true,`r`n    String? sexAtBirth,`r`n    String? genderIdentity,`r`n    String? pronouns,`r`n    String? customPronouns,"
    )
  }

  if ($repoContent -notmatch "'sex_at_birth': sexAtBirth") {
    $repoContent = $repoContent.Replace(
      "'voice_enabled': voiceEnabled,",
      "'voice_enabled': voiceEnabled,`r`n      'sex_at_birth': sexAtBirth,`r`n      'gender_identity': genderIdentity,`r`n      'pronouns': pronouns,`r`n      'custom_pronouns': customPronouns,"
    )
  }

  Set-Content -Path $profileRepo -Value $repoContent -NoNewline
  Write-Host "Patched profile repository identity persistence."
}

Write-Host "Avatar V4 Pass 3M onboarding purge + identity section applied."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
Write-Host "Manual Supabase SQL Editor:"
Write-Host "  supabase\migrations\202605060003_profile_identity_fields.sql"
