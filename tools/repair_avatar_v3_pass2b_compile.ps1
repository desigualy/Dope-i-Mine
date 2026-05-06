$ErrorActionPreference = "Stop"

Write-Host "Repairing Avatar V3 Pass 2B compile issue..."

$file = "lib\domain\avatar_v3\avatar_v3_migration.dart"

if (!(Test-Path $file)) {
  throw "Missing $file. Run from project root."
}

$content = Get-Content $file -Raw

$old = @'
  static bool _isStringStarterLikeProfile(string_profile.UserAvatarProfile value) {
    return value.imagePath == null &&
        value.remoteImageUrl == null &&
        (value.hairType == 'curly' || value.hairType == 'wavy') &&
        (value.hairStyle.isEmpty ||
            value.hairStyle == 'medium_wavy' ||
            value.hairStyle == 'mediumWavy');
  }
'@

$new = @'
  static bool _isStringStarterLikeProfile(string_profile.UserAvatarProfile value) {
    return (value.hairType == 'curly' || value.hairType == 'wavy') &&
        (value.hairStyle.isEmpty ||
            value.hairStyle == 'medium_wavy' ||
            value.hairStyle == 'mediumWavy' ||
            value.hairStyle == 'short');
  }
'@

if ($content.Contains($old)) {
  $content = $content.Replace($old, $new)
  Set-Content -Path $file -Value $content -NoNewline
  Write-Host "Removed unsupported imagePath/remoteImageUrl references."
} else {
  $content = $content -replace "return value\.imagePath == null &&\s*value\.remoteImageUrl == null &&\s*", "return "
  $content = $content -replace "value\.hairStyle == 'mediumWavy'\);", "value.hairStyle == 'mediumWavy' ||`r`n            value.hairStyle == 'short');"
  Set-Content -Path $file -Value $content -NoNewline
  Write-Host "Applied fallback regex repair."
}

Write-Host "Avatar V3 Pass 2B compile repair complete."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
