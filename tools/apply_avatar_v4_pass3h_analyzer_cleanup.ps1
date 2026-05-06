$ErrorActionPreference = "Stop"

Write-Host "Applying Avatar V4 Pass 3H analyzer cleanup..."

function Add-IgnoreForFile {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string]$Rule
  )

  if (!(Test-Path $Path)) {
    Write-Host "Skipped missing file: $Path"
    return
  }

  $content = Get-Content $Path -Raw

  if ($content -match "^// ignore_for_file:") {
    $firstLine = ($content -split "`r?`n", 2)[0]
    if ($firstLine -notmatch [regex]::Escape($Rule)) {
      $updatedFirstLine = $firstLine.TrimEnd() + ", $Rule"
      $content = $content.Substring($firstLine.Length)
      $content = $updatedFirstLine + $content
      Set-Content -Path $Path -Value $content -NoNewline
      Write-Host "Added $Rule to existing ignore_for_file in $Path"
    } else {
      Write-Host "$Path already ignores $Rule"
    }
  } else {
    Set-Content -Path $Path -Value ("// ignore_for_file: $Rule`r`n" + $content) -NoNewline
    Write-Host "Added ignore_for_file: $Rule to $Path"
  }
}

# 1. Fix quote-style info in Avatar V4 retirement policy.
$retirementFile = "lib\avatar_engine_v4\domain\avatar_v4_retirement_policy.dart"
if (Test-Path $retirementFile) {
  $content = Get-Content $retirementFile -Raw
  $content = $content.Replace('"presentation/avatar_v3/"', "'presentation/avatar_v3/'")
  $content = $content.Replace('"presentation/avatar/current_user_avatar_provider.dart"', "'presentation/avatar/current_user_avatar_provider.dart'")
  $content = $content.Replace('"presentation/avatar/user_avatar_renderer.dart"', "'presentation/avatar/user_avatar_renderer.dart'")
  Set-Content -Path $retirementFile -Value $content -NoNewline
  Write-Host "Fixed single-quote style in $retirementFile"
} else {
  Write-Host "Skipped missing $retirementFile"
}

# 2. Suppress known legacy unused helper without removing code.
$taskRepo = "lib\data\repositories\task_repository_impl.dart"
if (Test-Path $taskRepo) {
  $content = Get-Content $taskRepo -Raw
  if ($content -notmatch "// ignore: unused_element\s*`r?`n\s*[^`r`n]*_resolveBreakdownFocus") {
    $content = $content -replace "(?m)^(\s*[^`r`n]*_resolveBreakdownFocus\s*\()", "  // ignore: unused_element`r`n`$1"
    Set-Content -Path $taskRepo -Value $content -NoNewline
    Write-Host "Added unused_element ignore for _resolveBreakdownFocus."
  } else {
    Write-Host "_resolveBreakdownFocus already has unused_element ignore."
  }
} else {
  Write-Host "Skipped missing $taskRepo"
}

# 3. Silence legacy V3 prefer_const_declarations info without touching old V3 runtime behavior.
$v3ConstFiles = @(
  "lib\presentation\avatar_v3\current_avatar_v3_provider.dart",
  "test\avatar_v3\avatar_v3_hair_position_test.dart",
  "test\avatar_v3\avatar_v3_migration_test.dart",
  "test\avatar_v3\avatar_v3_profile_resolution_test.dart"
)

foreach ($file in $v3ConstFiles) {
  Add-IgnoreForFile -Path $file -Rule "prefer_const_declarations"
}

Write-Host "Avatar V4 Pass 3H analyzer cleanup applied."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
