$ErrorActionPreference = "Stop"

Write-Host "Repairing login short-password runtime path..."

$loginFile = "lib\presentation\auth\login_screen.dart"
$validatorFile = "lib\core\validators\auth_validators.dart"

if (!(Test-Path $loginFile)) {
  throw "Missing $loginFile. Run from project root."
}
if (!(Test-Path $validatorFile)) {
  throw "Missing $validatorFile. Run from project root."
}

$login = Get-Content $loginFile -Raw
$changedLogin = $false

if ($login.Contains("validatePassword(_passwordController.text);")) {
  $login = $login.Replace(
    "validatePassword(_passwordController.text);",
    "validateLoginPassword(_passwordController.text);"
  )
  $changedLogin = $true
  Write-Host "Changed LoginScreen to use validateLoginPassword."
} elseif ($login.Contains("validateLoginPassword(_passwordController.text);")) {
  Write-Host "LoginScreen already uses validateLoginPassword."
} else {
  Write-Host "No direct password validator call found in LoginScreen; leaving file unchanged."
}

if ($changedLogin) {
  Set-Content -Path $loginFile -Value $login -NoNewline
}

$validators = Get-Content $validatorFile -Raw
$oldStrictLoginValidator = @'
void validateLoginPassword(String value) {
  if (value.length < 8) {
    throw const AppFailure(
      'Password must be at least 8 characters.',
      code: 'weak_password',
    );
  }
}
'@

$newLoginValidator = @'
void validateLoginPassword(String value) {
  if (value.isEmpty) {
    throw const AppFailure(
      'Please enter your password.',
      code: 'missing_password',
    );
  }
}
'@

if ($validators.Contains($oldStrictLoginValidator)) {
  $validators = $validators.Replace($oldStrictLoginValidator, $newLoginValidator)
  Set-Content -Path $validatorFile -Value $validators -NoNewline
  Write-Host "Relaxed validateLoginPassword to allow existing shorter passwords."
} elseif ($validators.Contains("void validateLoginPassword(String value)") -and $validators.Contains("Please enter your password.")) {
  Write-Host "validateLoginPassword already allows existing shorter passwords."
} else {
  Write-Host "validateLoginPassword shape was not recognized; review manually if test still fails."
}

Write-Host "Login short-password runtime repair complete."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
