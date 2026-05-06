$ErrorActionPreference = "Stop"

Write-Host "Repairing Avatar V4 Pass 3M compile drift..."

$flowTest = "test\onboarding\onboarding_flow_test.dart"
$purgeTest = "test\avatar_v4\avatar_v4_onboarding_purge_test.dart"

if (!(Test-Path $flowTest)) {
  throw "Missing $flowTest. Run this from the project root."
}

$content = Get-Content $flowTest -Raw

# The fake repository extends ProfileRepositoryImpl, so its override must exactly match
# the new saveOnboardingProfile signature after identity fields were added.
if ($content -notmatch "String\? sexAtBirth") {
  $content = $content.Replace(
    "bool reduceSurprises = true,",
    "bool reduceSurprises = true,`r`n    String? sexAtBirth,`r`n    String? genderIdentity,`r`n    String? pronouns,`r`n    String? customPronouns,"
  )
  Write-Host "Patched _FakeProfileRepository.saveOnboardingProfile identity parameters."
} else {
  Write-Host "_FakeProfileRepository already has identity parameters."
}

Set-Content -Path $flowTest -Value $content -NoNewline

if (Test-Path $purgeTest) {
  $purge = Get-Content $purgeTest -Raw

  $purge = $purge.Replace('contains("data/avatar/")', "contains('data/avatar/')")
  $purge = $purge.Replace('contains("domain/avatar/user_avatar_profile.dart")', "contains('domain/avatar/user_avatar_profile.dart')")
  $purge = $purge.Replace('contains("AvatarCreatorScreen")', "contains('AvatarCreatorScreen')")
  $purge = $purge.Replace('contains("AvatarCandidateSelectorScreen")', "contains('AvatarCandidateSelectorScreen')")
  $purge = $purge.Replace('contains("AvatarPreviewCard")', "contains('AvatarPreviewCard')")
  $purge = $purge.Replace('contains("currentUserAvatarConfigProvider")', "contains('currentUserAvatarConfigProvider')")
  $purge = $purge.Replace('contains("AvatarRiveView")', "contains('AvatarRiveView')")
  $purge = $purge.Replace('contains("AvatarV4Config")', "contains('AvatarV4Config')")

  Set-Content -Path $purgeTest -Value $purge -NoNewline
  Write-Host "Patched onboarding purge test quotes."
}

Write-Host "Avatar V4 Pass 3M compile repair complete."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
