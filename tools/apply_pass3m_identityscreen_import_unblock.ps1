$ErrorActionPreference = "Stop"

Write-Host "Applying Pass 3M IdentityScreen import unblock..."

$file = "test\onboarding\onboarding_flow_test.dart"

if (!(Test-Path $file)) {
  throw "Missing $file. Run this from the project root."
}

$content = Get-Content $file -Raw

$identityImport = "import 'package:dope_i_mine/presentation/onboarding/identity_screen.dart';"

# Do not search for the loose text "identity_screen.dart" because the test file may
# contain that text inside string assertions. Check only the real import line.
if ($content -notmatch [regex]::Escape($identityImport)) {
  $avatarImport = "import 'package:dope_i_mine/presentation/onboarding/avatar_setup_screen.dart';"
  $voiceImport = "import 'package:dope_i_mine/presentation/onboarding/voice_setup_screen.dart';"

  if ($content.Contains($avatarImport)) {
    $content = $content.Replace($avatarImport, $avatarImport + "`r`n" + $identityImport)
    Write-Host "Inserted IdentityScreen import after avatar_setup_screen import."
  } elseif ($content.Contains($voiceImport)) {
    $content = $content.Replace($voiceImport, $voiceImport + "`r`n" + $identityImport)
    Write-Host "Inserted IdentityScreen import after voice_setup_screen import."
  } else {
    $content = $identityImport + "`r`n" + $content
    Write-Host "Inserted IdentityScreen import at top of file."
  }
} else {
  Write-Host "IdentityScreen import already present."
}

# Use non-const construction in test helper routes. This is valid whether the
# widget constructor is const or not, and avoids a second pointless compile stop.
$content = $content.Replace("const IdentityScreen(returnToSummary: false)", "IdentityScreen(returnToSummary: false)")

Set-Content -Path $file -Value $content -NoNewline

dart format $file | Out-Host

Write-Host "Pass 3M IdentityScreen import unblock complete."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
