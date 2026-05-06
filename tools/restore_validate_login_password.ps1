$ErrorActionPreference = "Stop"

Write-Host "Restoring validateLoginPassword..."

$validatorFile = "lib\core\validators\auth_validators.dart"
$loginFile = "lib\presentation\auth\login_screen.dart"

if (!(Test-Path $validatorFile)) {
  throw "Missing $validatorFile. Run this from the project root."
}
if (!(Test-Path $loginFile)) {
  throw "Missing $loginFile. Run this from the project root."
}

$validators = Get-Content $validatorFile -Raw

if ($validators -notmatch "void\s+validateLoginPassword\s*\(") {
  $insert = @'

void validateLoginPassword(String value) {
  if (value.isEmpty) {
    throw const AppFailure(
      'Please enter your password.',
      code: 'missing_password',
    );
  }
}

'@

  if ($validators -match "void\s+validatePassword\s*\(") {
    $validators = $validators -replace "(?m)^void\s+validatePassword\s*\(", ($insert + "void validatePassword(")
    Set-Content -Path $validatorFile -Value $validators -NoNewline
    Write-Host "Inserted validateLoginPassword before validatePassword."
  } else {
    $validators = $validators.TrimEnd() + $insert
    Set-Content -Path $validatorFile -Value $validators -NoNewline
    Write-Host "Appended validateLoginPassword."
  }
} else {
  Write-Host "validateLoginPassword already exists."
}

$login = Get-Content $loginFile -Raw

if ($login -notmatch "auth_validators\.dart") {
  $login = $login -replace "import '../../core/errors/user_facing_error_mapper.dart';", "import '../../core/errors/user_facing_error_mapper.dart';`r`nimport '../../core/validators/auth_validators.dart';"
  Set-Content -Path $loginFile -Value $login -NoNewline
  Write-Host "Restored auth_validators import."
} else {
  Write-Host "LoginScreen already imports auth_validators."
}

if ($login -match "validatePassword\(_passwordController\.text\);") {
  $login = Get-Content $loginFile -Raw
  $login = $login.Replace(
    "validatePassword(_passwordController.text);",
    "validateLoginPassword(_passwordController.text);"
  )
  Set-Content -Path $loginFile -Value $login -NoNewline
  Write-Host "LoginScreen now uses validateLoginPassword."
} elseif ($login -match "validateLoginPassword\(_passwordController\.text\);") {
  Write-Host "LoginScreen already uses validateLoginPassword."
}

Write-Host "validateLoginPassword restore complete."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
