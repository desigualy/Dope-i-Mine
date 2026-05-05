$ErrorActionPreference = "Stop"

$optionsPath = "lib/domain/avatar_v2/avatar_v2_options.dart"
$rendererPath = "lib/presentation/user_avatar/user_avatar_renderer.dart"

if (!(Test-Path $optionsPath)) {
  throw "Missing $optionsPath"
}
if (!(Test-Path $rendererPath)) {
  throw "Missing $rendererPath"
}

$options = Get-Content $optionsPath -Raw
if ($options -notmatch "case AvatarV2HairStyle\.taperedCoils:") {
  $options = $options.Replace(
"      case AvatarV2HairStyle.coilyCrop:
",
"      case AvatarV2HairStyle.coilyCrop:
      case AvatarV2HairStyle.taperedCoils:
"
  )
  Set-Content -Path $optionsPath -Value $options -NoNewline
  Write-Host "Patched taperedCoils exhaustive switch."
} else {
  Write-Host "taperedCoils switch case already present."
}

$renderer = Get-Content $rendererPath -Raw
if ($renderer -notmatch "bool get _isCurlyAfroHair") {
  $getter = @'
  bool get _isCurlyAfroHair {
    return profile.hairType == 'curly' ||
        profile.hairType == 'coily' ||
        profile.hairType == 'afro_textured' ||
        profile.hairStyle == 'afro' ||
        profile.hairStyle == 'full_curly_afro' ||
        profile.hairStyle == 'side_part_afro' ||
        profile.hairStyle == 'curly_afro_side_part' ||
        profile.hairStyle == 'tapered_afro' ||
        profile.hairStyle == 'coily_crop' ||
        profile.hairStyle == 'tapered_coils' ||
        profile.hairStyle == 'shoulder_length_curls' ||
        profile.hairStyle == 'long_ringlets' ||
        profile.hairStyle == 'short_curls';
  }


'@

  if ($renderer.Contains("  void _paintHairTexture(")) {
    $renderer = $renderer.Replace("  void _paintHairTexture(", $getter + "  void _paintHairTexture(")
    Set-Content -Path $rendererPath -Value $renderer -NoNewline
    Write-Host "Added _isCurlyAfroHair getter to fallback painter."
  } else {
    throw "Could not find _paintHairTexture insertion point in $rendererPath"
  }
} else {
  Write-Host "_isCurlyAfroHair getter already present."
}

Write-Host "Avatar V2 Pass 1 compile repair complete."
