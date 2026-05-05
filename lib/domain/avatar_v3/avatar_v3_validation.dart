import 'avatar_v3_options.dart';
import 'avatar_v3_profile.dart';

class AvatarV3ValidationResult {
  const AvatarV3ValidationResult({
    required this.profile,
    this.warnings = const <String>[],
  });

  final AvatarV3Profile profile;
  final List<String> warnings;

  bool get hasWarnings => warnings.isNotEmpty;
}

class AvatarV3Validation {
  const AvatarV3Validation._();

  static AvatarV3ValidationResult validate(AvatarV3Profile profile) {
    final normalized = AvatarV3Options.normalize(profile);
    final warnings = <String>[];

    if (normalized.hair.style != profile.hair.style) {
      warnings.add('Hair style normalized for selected hair type.');
    }

    if (normalized.facialHair.type != profile.facialHair.type) {
      warnings.add('Facial hair removed for child/pre-teen avatar.');
    }

    return AvatarV3ValidationResult(profile: normalized, warnings: warnings);
  }
}
