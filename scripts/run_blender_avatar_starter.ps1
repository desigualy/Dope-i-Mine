param(
  [string]$BlenderExe = ""
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $ScriptDir "..")
$BlenderScript = Join-Path $ProjectRoot "tools/avatar_assets/blender/create_base_avatar_starter.py"

if (!(Test-Path -LiteralPath $BlenderScript -PathType Leaf)) {
  Write-Host "Missing Blender script:" -ForegroundColor Red
  Write-Host " $BlenderScript"
  Write-Host ""
  Write-Host "Apply the avatar asset authoring patch first."
  exit 1
}

function Find-Blender {
  if ($BlenderExe -and (Test-Path -LiteralPath $BlenderExe -PathType Leaf)) {
    return $BlenderExe
  }

  $command = Get-Command blender -ErrorAction SilentlyContinue
  if ($command) {
    return $command.Source
  }

  $candidates = @(
    "C:\Program Files\Blender Foundation\Blender 4.5\blender.exe",
    "C:\Program Files\Blender Foundation\Blender 4.4\blender.exe",
    "C:\Program Files\Blender Foundation\Blender 4.3\blender.exe",
    "C:\Program Files\Blender Foundation\Blender 4.2\blender.exe",
    "C:\Program Files\Blender Foundation\Blender 4.1\blender.exe",
    "C:\Program Files\Blender Foundation\Blender 4.0\blender.exe",
    "C:\Program Files\Blender Foundation\Blender\blender.exe",
    "$env:LOCALAPPDATA\Microsoft\WindowsApps\blender.exe"
  )

  foreach ($candidate in $candidates) {
    if (Test-Path -LiteralPath $candidate -PathType Leaf) {
      return $candidate
    }
  }

  return $null
}

$ResolvedBlender = Find-Blender

if (!$ResolvedBlender) {
  Write-Host "Blender was not found." -ForegroundColor Red
  Write-Host ""
  Write-Host "Install Blender, then either:"
  Write-Host "1. Add blender.exe to PATH, or"
  Write-Host "2. Run this script with -BlenderExe, for example:"
  Write-Host '   powershell -ExecutionPolicy Bypass -File scripts/run_blender_avatar_starter.ps1 -BlenderExe "C:\Program Files\Blender Foundation\Blender 4.5\blender.exe"'
  exit 1
}

Write-Host "Using Blender:" -ForegroundColor Cyan
Write-Host " $ResolvedBlender"
Write-Host "Running script:" -ForegroundColor Cyan
Write-Host " $BlenderScript"

& $ResolvedBlender --background --python $BlenderScript

Write-Host ""
Write-Host "Blender starter avatar export complete." -ForegroundColor Green
Write-Host "Expected output:"
Write-Host " $ProjectRoot\assets\avatar_glb\base_avatar.glb"
