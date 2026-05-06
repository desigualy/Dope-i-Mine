$ErrorActionPreference = "Stop"

Write-Host "Repairing Avatar V4 Pass 3I FlutterError imports..."

$validator = "lib\avatar_engine_v4\runtime\avatar_rive_contract_validator.dart"
$test = "test\avatar_v4\avatar_v4_rive_contract_validator_test.dart"

if (!(Test-Path $validator)) {
  throw "Missing $validator. Run this from the project root."
}
if (!(Test-Path $test)) {
  throw "Missing $test. Run this from the project root."
}

$validatorContent = Get-Content $validator -Raw
if ($validatorContent -notmatch "package:flutter/foundation\.dart") {
  $validatorContent = $validatorContent.Replace(
    "import 'package:flutter/services.dart';",
    "import 'package:flutter/foundation.dart';`r`nimport 'package:flutter/services.dart';"
  )
  Set-Content -Path $validator -Value $validatorContent -NoNewline
  Write-Host "Added flutter/foundation.dart import to validator."
} else {
  Write-Host "Validator already imports flutter/foundation.dart."
}

$testContent = Get-Content $test -Raw
if ($testContent -notmatch "package:flutter/foundation\.dart") {
  $testContent = $testContent.Replace(
    "import 'package:flutter/services.dart';",
    "import 'package:flutter/foundation.dart';`r`nimport 'package:flutter/services.dart';"
  )
  Set-Content -Path $test -Value $testContent -NoNewline
  Write-Host "Added flutter/foundation.dart import to validator test."
} else {
  Write-Host "Validator test already imports flutter/foundation.dart."
}

Write-Host "Avatar V4 Pass 3I FlutterError import repair complete."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
