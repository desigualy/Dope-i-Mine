import 'avatar_enums.dart';

enum AvatarStylePreset {
  softIllustrated,
  semiRealisticPremium,
  realisticWarm,
  realisticNeon,
  privateAbstract,
}

extension AvatarStylePresetLabel on AvatarStylePreset {
  String get label {
    switch (this) {
      case AvatarStylePreset.softIllustrated:
        return 'Soft illustrated';
      case AvatarStylePreset.semiRealisticPremium:
        return 'Semi-realistic premium';
      case AvatarStylePreset.realisticWarm:
        return 'Realistic warm';
      case AvatarStylePreset.realisticNeon:
        return 'Realistic neon';
      case AvatarStylePreset.privateAbstract:
        return 'Private abstract';
    }
  }

  AvatarRenderMode get renderMode {
    switch (this) {
      case AvatarStylePreset.privateAbstract:
        return AvatarRenderMode.abstract;
      case AvatarStylePreset.softIllustrated:
        return AvatarRenderMode.premiumPortrait;
      case AvatarStylePreset.semiRealisticPremium:
      case AvatarStylePreset.realisticWarm:
      case AvatarStylePreset.realisticNeon:
        return AvatarRenderMode.ultraRealistic;
    }
  }

  AvatarRealismLevel get realismLevel {
    switch (this) {
      case AvatarStylePreset.softIllustrated:
        return AvatarRealismLevel.soft;
      case AvatarStylePreset.semiRealisticPremium:
        return AvatarRealismLevel.semiRealistic;
      case AvatarStylePreset.realisticWarm:
      case AvatarStylePreset.realisticNeon:
        return AvatarRealismLevel.ultraRealistic;
      case AvatarStylePreset.privateAbstract:
        return AvatarRealismLevel.soft;
    }
  }

  AvatarLightingStyle get lightingStyle {
    switch (this) {
      case AvatarStylePreset.softIllustrated:
        return AvatarLightingStyle.softNatural;
      case AvatarStylePreset.semiRealisticPremium:
        return AvatarLightingStyle.studio;
      case AvatarStylePreset.realisticWarm:
        return AvatarLightingStyle.warm;
      case AvatarStylePreset.realisticNeon:
        return AvatarLightingStyle.neon;
      case AvatarStylePreset.privateAbstract:
        return AvatarLightingStyle.cool;
    }
  }

  String get styleInstruction {
    switch (this) {
      case AvatarStylePreset.softIllustrated:
        return 'soft illustrated portrait, gentle shapes, warm approachable app avatar style';
      case AvatarStylePreset.semiRealisticPremium:
        return 'semi-realistic premium portrait, natural proportions, detailed but not uncanny, polished wellness app style';
      case AvatarStylePreset.realisticWarm:
        return 'realistic warm portrait, natural skin texture, soft studio light, not passport-photo, friendly and dignified';
      case AvatarStylePreset.realisticNeon:
        return 'realistic portrait with tasteful subtle neon rim light, modern app identity, still natural and dignified';
      case AvatarStylePreset.privateAbstract:
        return 'private abstract non-human identity symbol, soft aura, no face, no body, no biometric likeness';
    }
  }
}
