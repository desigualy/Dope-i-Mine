$ErrorActionPreference = "Stop"

Write-Host "Verifying Avatar V4 base Rive asset..."

$requiredFiles = @(
  "assets\avatar_rive\base_avatar.riv",
  "assets\avatar_rive\base_avatar_import_manifest.json",
  "assets\avatar_rive\avatar_v4_rive_handoff.json",
  "docs\avatar_v4\AVATAR_V4_RIVE_HANDOFF_SPEC.md",
  "docs\avatar_v4\AVATAR_V4_RIVE_INPUT_MAP.md",
  "docs\avatar_v4\AVATAR_V4_LAYER_NAMING_CONTRACT.md",
  "docs\avatar_v4\AVATAR_V4_QA_CHECKLIST.md",
  "docs\avatar_v4\AVATAR_V4_ARTIST_BRIEF.md",
  "docs\avatar_v4\AVATAR_V4_BASE_RIVE_BUILD_WORKFLOW.md",
  "docs\avatar_v4\AVATAR_V4_RIVE_ARTIST_DELIVERY_CHECKLIST.md",
  "docs\avatar_v4\AVATAR_V4_RIVE_IMPORT_QA_RUNBOOK.md"
)

foreach ($file in $requiredFiles) {
  if (!(Test-Path $file)) {
    throw "Missing required file: $file"
  }
  Write-Host "Found $file"
}

$rive = Get-Item "assets\avatar_rive\base_avatar.riv"
if ($rive.Length -le 0) {
  throw "assets\avatar_rive\base_avatar.riv is empty."
}

Write-Host "base_avatar.riv size: $($rive.Length) bytes"
Write-Host "Static asset verification passed."
Write-Host ""
Write-Host "Important: this script cannot inspect Rive state machine inputs."
Write-Host "Confirm in Rive:"
Write-Host "  Artboard: Avatar"
Write-Host "  State machine: AvatarState"
Write-Host "  Inputs: skinTone, faceShape, hairPack, hairStyle, hairColor, bodyPreset, freckles, vitiligo, hasFacialHair, hasGlasses"
