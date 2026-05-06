$ErrorActionPreference = "Stop"

Write-Host "Locking Avatar V4 Pass 3M green state..."

$lockDir = "docs\avatar_v4"
$lockFile = "$lockDir\AVATAR_V4_PASS3M_GREEN_LOCK.md"

if (!(Test-Path $lockDir)) {
  New-Item -ItemType Directory -Force -Path $lockDir | Out-Null
}

Write-Host "Running flutter analyze..."
flutter analyze
if ($LASTEXITCODE -ne 0) {
  throw "flutter analyze failed. Pass 3M cannot be locked."
}

Write-Host "Running flutter test..."
flutter test
if ($LASTEXITCODE -ne 0) {
  throw "flutter test failed. Pass 3M cannot be locked."
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss K"

$body = @"
# Avatar V4 Pass 3M Green Lock

Locked at: $timestamp

## Verification

```text
flutter analyze -> No issues found
flutter test    -> All tests passed
```

## Locked Contracts

```text
Avatar V4 / Rive path is active.
Old public Avatar V3 onboarding surface is retired.
Onboarding includes Sex, Gender & Pronouns identity step.
Voice setup routes to /onboarding/identity.
Identity routes to /onboarding/avatar.
Avatar setup routes to /onboarding/summary.
Router exposes /onboarding/identity.
Onboarding summary persists identity fields.
Profile repository writes:
- sex_at_birth
- gender_identity
- pronouns
- custom_pronouns
```

## Do Not Re-run

Do not re-run Pass 3M repair scripts unless a future change deliberately touches onboarding identity, avatar setup, or route wiring.

## Next Safe Work

Proceed only from this green state.
"@

Set-Content -Path $lockFile -Value $body -NoNewline

Write-Host "Created $lockFile"

if (Get-Command git -ErrorAction SilentlyContinue) {
  Write-Host ""
  Write-Host "Current git status:"
  git status --short
  Write-Host ""
  Write-Host "Suggested checkpoint command:"
  Write-Host "  git add ."
  Write-Host "  git commit -m `"lock avatar v4 pass 3m green state`""
}

Write-Host "Avatar V4 Pass 3M green state locked."
