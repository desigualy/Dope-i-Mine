$ErrorActionPreference = "Stop"

function Write-Step {
  param([Parameter(Mandatory=$true)][string]$Message)
  Write-Host ""
  Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-Pass {
  param([Parameter(Mandatory=$true)][string]$Message)
  Write-Host "PASS: $Message" -ForegroundColor Green
}

function Write-Warn {
  param([Parameter(Mandatory=$true)][string]$Message)
  Write-Host "WARN: $Message" -ForegroundColor Yellow
}

function Assert-RepoRoot {
  if (-not (Test-Path "pubspec.yaml")) {
    throw "Run this script from the Flutter repo root. pubspec.yaml was not found."
  }
}

function Invoke-Checked {
  param(
    [Parameter(Mandatory=$true)][string]$Label,
    [Parameter(Mandatory=$true)][scriptblock]$Command
  )

  Write-Step $Label
  & $Command
  if ($LASTEXITCODE -ne $null -and $LASTEXITCODE -ne 0) {
    throw "$Label failed with exit code $LASTEXITCODE"
  }
  Write-Pass $Label
}

function Invoke-OptionalSql {
  param([Parameter(Mandatory=$true)][string]$SqlPath)

  if (-not (Test-Path $SqlPath)) {
    Write-Warn "Skipping missing SQL check: $SqlPath"
    return
  }

  if ([string]::IsNullOrWhiteSpace($env:SUPABASE_DB_URL)) {
    throw "SUPABASE_DB_URL is not set. Set it before running SQL checks."
  }

  Invoke-Checked "SQL check: $SqlPath" {
    psql "$env:SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f $SqlPath
  }
}

function Invoke-OptionalFlutterTest {
  param([Parameter(Mandatory=$true)][string]$TestPath)

  if (-not (Test-Path $TestPath)) {
    Write-Warn "Skipping missing Flutter test path: $TestPath"
    return
  }

  Invoke-Checked "Flutter test: $TestPath" {
    flutter test $TestPath
  }
}

function Show-EnvironmentSummary {
  Write-Step "Environment summary"
  Write-Host "PowerShell: $($PSVersionTable.PSVersion)"
  Write-Host "Repo: $(Get-Location)"
  Write-Host "SUPABASE_DB_URL set: $(-not [string]::IsNullOrWhiteSpace($env:SUPABASE_DB_URL))"
}
