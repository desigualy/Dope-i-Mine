$ErrorActionPreference = "Stop"

$profilePath = "lib/domain/avatar_v2/avatar_v2_profile.dart"
if (!(Test-Path $profilePath)) {
  throw "Missing $profilePath"
}

$profile = Get-Content $profilePath -Raw

$old = @'
    final nextAge = agePresentation ?? this.agePresentation;
    final nextFacialHair = (nextAge == AvatarV2AgePresentation.child ||
            nextAge == AvatarV2AgePresentation.preTeen)
        ? const AvatarV2FacialHair()
        : facialHair ?? this.facialHair;

    return AvatarV2Profile(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      renderMode: renderMode ?? this.renderMode,
      realismLevel: realismLevel ?? this.realismLevel,
      lightingStyle: lightingStyle ?? this.lightingStyle,
      cameraStyle: cameraStyle ?? this.cameraStyle,
      agePresentation: nextAge,
      face: face ?? this.face,
      skin: skin ?? this.skin,
      hair: hair ?? this.hair,
      facialHair: nextFacialHair,
'@

$new = @'
    return AvatarV2Profile(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      renderMode: renderMode ?? this.renderMode,
      realismLevel: realismLevel ?? this.realismLevel,
      lightingStyle: lightingStyle ?? this.lightingStyle,
      cameraStyle: cameraStyle ?? this.cameraStyle,
      agePresentation: agePresentation ?? this.agePresentation,
      face: face ?? this.face,
      skin: skin ?? this.skin,
      hair: hair ?? this.hair,
      facialHair: facialHair ?? this.facialHair,
'@

if ($profile.Contains($old)) {
  $profile = $profile.Replace($old, $new)
  Set-Content -Path $profilePath -Value $profile -NoNewline
  Write-Host "Patched AvatarV2Profile.copyWith so validation can report normalization warnings."
} elseif ($profile.Contains("facialHair: facialHair ?? this.facialHair,")) {
  Write-Host "AvatarV2Profile.copyWith already uses validation-owned normalization."
} else {
  throw "Could not find expected AvatarV2Profile.copyWith block. Open $profilePath and remove automatic child/pre-teen facial hair normalization from copyWith."
}

Write-Host "Avatar V2 Pass 1 validation repair complete."
