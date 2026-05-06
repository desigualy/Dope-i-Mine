param(
  [Parameter(Mandatory = $true)]
  [string]$SourcePath
)

$ErrorActionPreference = "Stop"

Write-Host "Importing Avatar V4 base Rive asset..."

if (!(Test-Path $SourcePath)) {
  throw "Source .riv file not found: $SourcePath"
}

if ([System.IO.Path]::GetExtension($SourcePath).ToLowerInvariant() -ne ".riv") {
  throw "Source file must have .riv extension: $SourcePath"
}

$projectRoot = Get-Location
$targetDir = Join-Path $projectRoot "assets\avatar_rive"
$targetFile = Join-Path $targetDir "base_avatar.riv"

New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

$sourceItem = Get-Item $SourcePath
if ($sourceItem.Length -le 0) {
  throw "Source .riv file is empty: $SourcePath"
}

Copy-Item -Force $SourcePath $targetFile

$targetItem = Get-Item $targetFile
if ($targetItem.Length -le 0) {
  throw "Imported .riv file is empty: $targetFile"
}

Write-Host "Imported $SourcePath"
Write-Host "To $targetFile"
Write-Host "Size: $($targetItem.Length) bytes"
Write-Host ""
Write-Host "Next:"
Write-Host "  .\tools\verify_avatar_v4_base_rive.ps1"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
Write-Host "  flutter run"
