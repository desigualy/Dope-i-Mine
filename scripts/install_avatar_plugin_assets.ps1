param(
  [string]$RivePath = "assets/avatar_rive/base_avatar.riv",
  [string]$GlbPath = "assets/avatar_glb/base_avatar.glb"
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $ScriptDir "..")

function Resolve-ProjectPath($Path) {
  if ([System.IO.Path]::IsPathRooted($Path)) {
    return $Path
  }

  return Join-Path $ProjectRoot $Path
}

function Show-NearMatches($Path) {
  $folder = Split-Path -Parent $Path

  if (Test-Path $folder) {
    Write-Host ""
    Write-Host "Files found in ${folder}:" -ForegroundColor Yellow
    Get-ChildItem $folder -Force |
      Where-Object { $_.Name -like "*base_avatar*" -or $_.Name -like "*.riv*" -or $_.Name -like "*.glb*" } |
      ForEach-Object { Write-Host (" - " + $_.Name) }
  } else {
    Write-Host ""
    Write-Host "Folder does not exist: ${folder}" -ForegroundColor Yellow
  }
}

function Require-File($Path, $Label) {
  $FullPath = Resolve-ProjectPath $Path

  Write-Host "$Label expected path:" -ForegroundColor DarkCyan
  Write-Host " $FullPath"

  if (!(Test-Path -LiteralPath $FullPath -PathType Leaf)) {
    Write-Host ""
    Write-Host "Missing $Label asset: $Path" -ForegroundColor Red
    Show-NearMatches $FullPath
    Write-Host ""
    Write-Host "The file must be named exactly:" -ForegroundColor Yellow
    Write-Host " $(Split-Path -Leaf $FullPath)"
    exit 1
  }

  return $FullPath
}

Write-Host "Checking production avatar plugin assets..." -ForegroundColor Cyan
Write-Host "Project root: $ProjectRoot"

$ResolvedRivePath = Require-File $RivePath "Rive"
$ResolvedGlbPath = Require-File $GlbPath "GLB"

Write-Host ""
Write-Host "Uploading Rive rig to Supabase Storage..." -ForegroundColor Cyan
npx.cmd supabase storage cp $ResolvedRivePath "ss://avatar-rive-rigs/base_avatar.riv" --experimental

Write-Host "Uploading GLB avatar to Supabase Storage..." -ForegroundColor Cyan
npx.cmd supabase storage cp $ResolvedGlbPath "ss://avatar-glb-assets/base_avatar.glb" --experimental

Write-Host "Deploying resolver/sync functions..." -ForegroundColor Cyan
npx.cmd supabase functions deploy resolve-avatar-assets
npx.cmd supabase functions deploy sync-avatar-plugin-profile

Write-Host ""
Write-Host "Production avatar plugin assets uploaded." -ForegroundColor Green
Write-Host "Now open the app > Avatar > Resolve plugin avatar."
