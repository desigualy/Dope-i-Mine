import 'avatar_v2_layers.dart';
import 'avatar_v2_options.dart';
import 'avatar_v2_profile.dart';

class AvatarV2ValidationResult {
  const AvatarV2ValidationResult({
    required this.isValid,
    this.errors = const <String>[],
    this.warnings = const <String>[],
    this.normalized,
  });

  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final AvatarV2Profile? normalized;
}

class AvatarV2Validation {
  const AvatarV2Validation._();

  static AvatarV2ValidationResult validate(AvatarV2Profile profile) {
    final errors = <String>[];
    final warnings = <String>[];
    var normalized = profile;

    if (profile.isChildLike && !profile.facialHair.isNone) {
      warnings.add('Child and pre-teen avatars cannot render adult facial hair.');
      normalized = normalized.copyWith(facialHair: const AvatarV2FacialHair());
    }

    final allowedStyles = AvatarV2Options.hairStylesFor(profile.hair.texture);
    if (!allowedStyles.contains(profile.hair.style)) {
      warnings.add(
        '${profile.hair.style.label} is not valid for ${profile.hair.texture.label}.',
      );
      final nextStyle = AvatarV2Options.defaultHairStyleFor(profile.hair.texture);
      normalized = normalized.copyWith(
        hair: normalized.hair.copyWith(
          style: nextStyle,
          length: AvatarV2Options.defaultHairLengthFor(nextStyle),
          frontStrandPolicy: AvatarV2Options.frontPolicyFor(nextStyle),
        ),
      );
    }

    if (_isAfroFamily(profile.hair.texture) &&
        profile.hair.frontStrandPolicy == AvatarV2FrontStrandPolicy.fringeAllowed) {
      warnings.add('Afro/coily styles cannot use front-face fringe overlap.');
      normalized = normalized.copyWith(
        hair: normalized.hair.copyWith(
          frontStrandPolicy: AvatarV2FrontStrandPolicy.noFaceOverlap,
        ),
      );
    }

    if (_isStrandFamily(profile.hair.texture) &&
        profile.hair.frontStrandPolicy == AvatarV2FrontStrandPolicy.fringeAllowed) {
      warnings.add('Locs, braids, and twists must stay rooted from scalp zones.');
      normalized = normalized.copyWith(
        hair: normalized.hair.copyWith(
          frontStrandPolicy: AvatarV2FrontStrandPolicy.noFaceOverlap,
        ),
      );
    }

    if (profile.facialHair.type == AvatarV2FacialHairType.moustache &&
        profile.facialHair.chinCoverage != AvatarV2ChinCoverage.none) {
      warnings.add('Moustache cannot include chin coverage.');
      normalized = normalized.copyWith(
        facialHair: normalized.facialHair.copyWith(
          chinCoverage: AvatarV2ChinCoverage.none,
          jawCoverage: AvatarV2JawCoverage.none,
          cheekCoverage: AvatarV2CheekCoverage.none,
        ),
      );
    }

    if (profile.mode == AvatarV2Mode.privateAbstract && profile.referenceImage.hasImage) {
      warnings.add('Private abstract mode ignores human likeness reference images.');
    }

    final layerPlan = const AvatarV2LayerPlanner().planFor(normalized);
    if (layerPlan.hasUnsafeFaceOverlap) {
      errors.add('Layer plan contains unsafe face overlap.');
    }

    return AvatarV2ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
      normalized: normalized,
    );
  }

  static bool _isAfroFamily(AvatarV2HairTexture texture) {
    return texture == AvatarV2HairTexture.afro ||
        texture == AvatarV2HairTexture.coily;
  }

  static bool _isStrandFamily(AvatarV2HairTexture texture) {
    return texture == AvatarV2HairTexture.locs ||
        texture == AvatarV2HairTexture.braids ||
        texture == AvatarV2HairTexture.twists;
  }
}
