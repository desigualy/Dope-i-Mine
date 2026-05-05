$ErrorActionPreference = "Stop"

function Add-ImportIfMissing {
  param(
    [string]$Path,
    [string]$Import
  )
  $content = Get-Content $Path -Raw
  if ($content -notmatch [regex]::Escape($Import)) {
    $content = $content -replace "(import '[^']+';\r?\n)", "`$1$Import`n"
    Set-Content -Path $Path -Value $content -NoNewline
    Write-Host "Added import to $Path: $Import"
  }
}

# Copy patch files into the repo.
$patchRoot = Split-Path -Parent $PSScriptRoot
$files = @(
  "lib/data/local/local_avatar_v2_store.dart",
  "lib/domain/avatar_v2/avatar_v2_legacy_bridge.dart",
  "lib/presentation/avatar_v2/current_avatar_v2_provider.dart",
  "lib/presentation/avatar_v2/avatar_v2_live_widgets.dart"
)

foreach ($file in $files) {
  $source = Join-Path $patchRoot $file
  $target = Join-Path (Get-Location) $file
  if (!(Test-Path $source)) {
    throw "Patch source missing: $source"
  }
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
  Copy-Item -Force $source $target
  Write-Host "Installed $file"
}

# Home: use Avatar V2 hero as live home avatar while preserving the old subtitle/config code.
$home = "lib/presentation/home/home_screen.dart"
if (Test-Path $home) {
  Add-ImportIfMissing -Path $home -Import "import '../avatar_v2/avatar_v2_live_widgets.dart';"

  $content = Get-Content $home -Raw
  if ($content -notmatch "AvatarV2HomeHero") {
    $pattern = "_HomeAvatarHero\(\s*configState:\s*userAvatarConfig,\s*mood:\s*avatarMood,\s*\),"
    $content = [regex]::Replace($content, $pattern, "const AvatarV2HomeHero(),", 1)
    Set-Content -Path $home -Value $content -NoNewline
    Write-Host "Wired AvatarV2HomeHero into HomeScreen."
  } else {
    Write-Host "HomeScreen already references AvatarV2HomeHero."
  }
} else {
  throw "Missing $home"
}

# Settings companion/avatar screen: add Avatar V2 panel before the legacy preview.
$settings = "lib/presentation/settings/companion_screen.dart"
if (Test-Path $settings) {
  Add-ImportIfMissing -Path $settings -Import "import '../avatar_v2/avatar_v2_live_widgets.dart';"

  $content = Get-Content $settings -Raw
  if ($content -notmatch "AvatarV2SettingsPanel") {
    $needle = "children: <Widget>["
    $insert = "children: <Widget>[`n                const AvatarV2SettingsPanel(),`n                const SizedBox(height: 16),"
    $content = $content.Replace($needle, $insert)
    Set-Content -Path $settings -Value $content -NoNewline
    Write-Host "Added AvatarV2SettingsPanel to CompanionScreen."
  } else {
    Write-Host "CompanionScreen already has AvatarV2SettingsPanel."
  }
} else {
  throw "Missing $settings"
}

# Onboarding avatar step: add Avatar V2 panel before the legacy preview.
$onboarding = "lib/presentation/onboarding/avatar_setup_screen.dart"
if (Test-Path $onboarding) {
  Add-ImportIfMissing -Path $onboarding -Import "import '../avatar_v2/avatar_v2_live_widgets.dart';"

  $content = Get-Content $onboarding -Raw
  if ($content -notmatch "AvatarV2OnboardingPanel") {
    $needle = "children: <Widget>["
    $insert = "children: <Widget>[`n                const AvatarV2OnboardingPanel(),`n                const SizedBox(height: 16),"
    $content = $content.Replace($needle, $insert)
    Set-Content -Path $onboarding -Value $content -NoNewline
    Write-Host "Added AvatarV2OnboardingPanel to AvatarSetupScreen."
  } else {
    Write-Host "AvatarSetupScreen already has AvatarV2OnboardingPanel."
  }
} else {
  throw "Missing $onboarding"
}

Write-Host "Avatar V2 Pass 2 wiring complete."
