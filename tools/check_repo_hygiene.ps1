# Dope-i-Mine repository hygiene checker
# Run from the project root:
#   powershell -ExecutionPolicy Bypass -File .\tools\check_repo_hygiene.ps1

$ErrorActionPreference = "Stop"

Write-Host "Checking tracked files that should normally not be committed..." -ForegroundColor Cyan

$patterns = @(
  '\.flutter-plugins-dependencies$',
  '^\.flutter-plugins$',
  '^\.idea/',
  '^\.dart_tool/',
  '^build/',
  '^\.env$',
  '^\.env\.json$',
  '\.iml$',
  '\.log$',
  '\.tmp$',
  'dope_i_mine_debug_pass\.patch$',
  'APPLY_DEBUG_PASS\.md$'
)

$trackedFiles = git ls-files
$badFiles = New-Object System.Collections.Generic.List[string]

foreach ($file in $trackedFiles) {
  foreach ($pattern in $patterns) {
    if ($file -match $pattern) {
      $badFiles.Add($file)
      break
    }
  }
}

if ($badFiles.Count -eq 0) {
  Write-Host "PASS: No tracked generated/local/secret-style files found." -ForegroundColor Green
  exit 0
}

Write-Host "FAIL: These files are tracked and should be reviewed/removed from Git tracking:" -ForegroundColor Red
$badFiles | Sort-Object -Unique | ForEach-Object {
  Write-Host " - $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Suggested cleanup examples:" -ForegroundColor Cyan
Write-Host "git rm --cached .flutter-plugins-dependencies"
Write-Host "git rm -r --cached .idea"
Write-Host "git rm -r --cached .dart_tool"
Write-Host "git rm -r --cached build"
Write-Host "git rm --cached .env .env.json"
Write-Host ""
Write-Host "Only run cleanup commands for files that actually appear above." -ForegroundColor Cyan

exit 1
