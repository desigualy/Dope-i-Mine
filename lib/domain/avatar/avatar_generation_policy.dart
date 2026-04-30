import 'avatar_enums.dart';
import 'user_avatar_profile.dart';

class AvatarGenerationPolicy {
  const AvatarGenerationPolicy({
    required this.allowRealisticGeneration,
    required this.allowCloudStorage,
    required this.allowFaceUpload,
    required this.requireGuardianConsent,
    required this.mustUseMinorSafePrompt,
    required this.defaultRenderMode,
    required this.defaultRealismLevel,
  });

  final bool allowRealisticGeneration;
  final bool allowCloudStorage;
  final bool allowFaceUpload;
  final bool requireGuardianConsent;
  final bool mustUseMinorSafePrompt;
  final AvatarRenderMode defaultRenderMode;
  final AvatarRealismLevel defaultRealismLevel;

  static AvatarGenerationPolicy forProfile(UserAvatarProfile profile) {
    final isMinor = profile.agePresentation == AvatarAgePresentation.child ||
        profile.agePresentation == AvatarAgePresentation.preTeen ||
        profile.agePresentation == AvatarAgePresentation.teen;

    return AvatarGenerationPolicy(
      allowRealisticGeneration: true,
      allowCloudStorage: !isMinor,
      allowFaceUpload: false,
      requireGuardianConsent: isMinor,
      mustUseMinorSafePrompt: isMinor,
      defaultRenderMode: isMinor
          ? AvatarRenderMode.premiumPortrait
          : AvatarRenderMode.ultraRealistic,
      defaultRealismLevel: isMinor
          ? AvatarRealismLevel.semiRealistic
          : AvatarRealismLevel.semiRealistic,
    );
  }

  List<String> warningsFor(UserAvatarProfile profile) {
    final warnings = <String>[];

    if (requireGuardianConsent) {
      warnings.add(
        'Guardian consent may be required before realistic avatar generation.',
      );
    }

    if (!allowFaceUpload) {
      warnings.add(
        'Real face uploads are disabled. Avatar generation uses choices only.',
      );
    }

    if (mustUseMinorSafePrompt) {
      warnings.add(
        'Minor-safe generation rules are enabled.',
      );
    }

    if (profile.mode == AvatarMode.privateAbstract) {
      warnings.add(
        'Private abstract mode avoids human likeness by design.',
      );
    }

    return warnings;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'allowRealisticGeneration': allowRealisticGeneration,
      'allowCloudStorage': allowCloudStorage,
      'allowFaceUpload': allowFaceUpload,
      'requireGuardianConsent': requireGuardianConsent,
      'mustUseMinorSafePrompt': mustUseMinorSafePrompt,
      'defaultRenderMode': defaultRenderMode.name,
      'defaultRealismLevel': defaultRealismLevel.name,
    };
  }
}
