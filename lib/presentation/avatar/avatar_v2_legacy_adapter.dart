import '../../domain/avatar/avatar_enums.dart' as legacy;
import '../../domain/avatar/user_avatar_profile.dart' as legacy_profile;
import '../../domain/avatar_v2/avatar_v2_profile.dart';

class AvatarV2LegacyAdapter {
  const AvatarV2LegacyAdapter._();

  static AvatarV2Profile fromLegacy(legacy_profile.UserAvatarProfile profile) {
    final hairTexture = _hairTexture(profile.hairType);
    final hairStyle = _hairStyle(profile.hairType, profile.hairStyle);
    final facialHairType = _facialHairType(profile.facialHair);

    return AvatarV2Profile(
      mode: _mode(profile.mode),
      renderMode: AvatarV2RenderMode.realtimeVector,
      realismLevel: _realism(profile.realismLevel),
      lightingStyle: _lighting(profile.lightingStyle),
      cameraStyle: _camera(profile.cameraStyle),
      agePresentation: _age(profile.agePresentation),
      face: AvatarV2Face(
        shape: _faceShape(profile.faceShape),
        expression: _expression(profile.expression),
      ),
      skin: AvatarV2Skin(
        tone: _skinTone(profile.skinTone),
        freckles: profile.skinDetail == legacy.AvatarSkinDetail.freckles
            ? const AvatarV2Freckles(
                density: AvatarV2FreckleDensity.medium,
                distribution: AvatarV2FreckleDistribution.noseAndCheeks,
              )
            : const AvatarV2Freckles(),
        vitiligo: profile.skinDetail == legacy.AvatarSkinDetail.vitiligo
            ? const AvatarV2Vitiligo(
                pattern: AvatarV2VitiligoPattern.asymmetrical,
                intensity: AvatarV2DetailIntensity.visible,
              )
            : const AvatarV2Vitiligo(),
        birthmarks: profile.skinDetail == legacy.AvatarSkinDetail.birthmark
            ? const <AvatarV2Birthmark>[
                AvatarV2Birthmark(
                  type: AvatarV2BirthmarkType.flatPatch,
                  location: AvatarV2FaceRegion.leftCheek,
                  size: AvatarV2DetailSize.medium,
                  intensity: AvatarV2DetailIntensity.visible,
                ),
              ]
            : const <AvatarV2Birthmark>[],
        scars: profile.skinDetail == legacy.AvatarSkinDetail.scar
            ? const <AvatarV2Scar>[
                AvatarV2Scar(
                  type: AvatarV2ScarType.fineLine,
                  location: AvatarV2FaceRegion.rightCheek,
                  size: AvatarV2DetailSize.medium,
                  intensity: AvatarV2DetailIntensity.visible,
                  orientation: AvatarV2MarkOrientation.diagonal,
                ),
              ]
            : const <AvatarV2Scar>[],
        matureLines: profile.skinDetail == legacy.AvatarSkinDetail.matureLines ||
                profile.agePresentation == legacy.AvatarAgePresentation.olderAdult
            ? const AvatarV2MatureLines(
                forehead: AvatarV2LineStrength.visible,
                crowsFeet: AvatarV2LineStrength.visible,
                smileLines: AvatarV2LineStrength.visible,
                underEye: AvatarV2LineStrength.subtle,
              )
            : const AvatarV2MatureLines(),
      ),
      hair: AvatarV2Hair(
        texture: hairTexture,
        style: hairStyle,
        length: _hairLength(profile.hairLength, hairTexture, hairStyle),
        density: hairTexture == AvatarV2HairTexture.afro ||
                hairTexture == AvatarV2HairTexture.coily
            ? AvatarV2HairDensity.dense
            : AvatarV2HairDensity.medium,
        volume: _hairVolume(hairTexture, hairStyle),
        parting: hairStyle == AvatarV2HairStyle.sidePartAfro
            ? AvatarV2HairParting.side
            : AvatarV2HairParting.none,
        hairline: profile.hairType == legacy.AvatarHairType.shaved
            ? AvatarV2Hairline.shaved
            : AvatarV2Hairline.natural,
        colour: _hairColour(profile.hairColor),
        frontStrandPolicy: _frontStrandPolicy(hairTexture, hairStyle),
      ),
      facialHair: AvatarV2FacialHair(
        type: facialHairType,
        density: facialHairType == AvatarV2FacialHairType.fullBeard
            ? AvatarV2FacialHairDensity.dense
            : AvatarV2FacialHairDensity.medium,
        length: facialHairType == AvatarV2FacialHairType.fullBeard
            ? AvatarV2FacialHairLength.medium
            : AvatarV2FacialHairLength.short,
        colour: _hairColour(profile.hairColor),
        moustache: facialHairType == AvatarV2FacialHairType.moustache ||
                facialHairType == AvatarV2FacialHairType.goatee ||
                facialHairType == AvatarV2FacialHairType.shortBeard ||
                facialHairType == AvatarV2FacialHairType.fullBeard
            ? AvatarV2MoustacheStyle.natural
            : AvatarV2MoustacheStyle.none,
        cheekCoverage: facialHairType == AvatarV2FacialHairType.fullBeard
            ? AvatarV2CheekCoverage.full
            : AvatarV2CheekCoverage.none,
        jawCoverage: facialHairType == AvatarV2FacialHairType.shortBeard ||
                facialHairType == AvatarV2FacialHairType.fullBeard
            ? AvatarV2JawCoverage.jawAndChin
            : AvatarV2JawCoverage.none,
        chinCoverage: facialHairType == AvatarV2FacialHairType.goatee
            ? AvatarV2ChinCoverage.goatee
            : facialHairType == AvatarV2FacialHairType.shortBeard ||
                    facialHairType == AvatarV2FacialHairType.fullBeard
                ? AvatarV2ChinCoverage.full
                : AvatarV2ChinCoverage.none,
      ),
      body: AvatarV2Body(
        frame: _body(profile.bodyPresentation),
        shoulderWidth: _shoulder(profile.bodyPresentation),
        neck: profile.bodyPresentation == legacy.AvatarBodyPresentation.slim ||
                profile.bodyPresentation == legacy.AvatarBodyPresentation.petite
            ? AvatarV2NeckStyle.long
            : AvatarV2NeckStyle.average,
        visibleRange: AvatarV2VisibleRange.headAndShoulders,
      ),
      accessibility: AvatarV2Accessibility(
        glasses: profile.accessibilityItems.contains(legacy.AvatarAccessibilityItem.glasses)
            ? AvatarV2Glasses.rectangle
            : AvatarV2Glasses.none,
        hearingAid: profile.accessibilityItems.contains(legacy.AvatarAccessibilityItem.hearingAidLeft) &&
                profile.accessibilityItems.contains(legacy.AvatarAccessibilityItem.hearingAidRight)
            ? AvatarV2HearingAid.both
            : profile.accessibilityItems.contains(legacy.AvatarAccessibilityItem.hearingAidLeft)
                ? AvatarV2HearingAid.left
                : profile.accessibilityItems.contains(legacy.AvatarAccessibilityItem.hearingAidRight)
                    ? AvatarV2HearingAid.right
                    : AvatarV2HearingAid.none,
        cochlearImplant: profile.accessibilityItems.contains(legacy.AvatarAccessibilityItem.cochlearImplant)
            ? AvatarV2CochlearImplant.left
            : AvatarV2CochlearImplant.none,
        sensoryHeadphones: profile.accessibilityItems.contains(legacy.AvatarAccessibilityItem.sensoryHeadphones)
            ? AvatarV2SensoryHeadphones.overEar
            : AvatarV2SensoryHeadphones.none,
        medicalPatch: profile.accessibilityItems.contains(legacy.AvatarAccessibilityItem.medicalPatch)
            ? AvatarV2MedicalPatch.chest
            : AvatarV2MedicalPatch.none,
        glucoseMonitor: profile.accessibilityItems.contains(legacy.AvatarAccessibilityItem.glucoseMonitor)
            ? AvatarV2GlucoseMonitor.leftArm
            : AvatarV2GlucoseMonitor.none,
      ),
      clothing: const AvatarV2Clothing(),
      displayName: null,
      pronouns: null,
      avatarName: null,
    );
  }

  static AvatarV2Mode _mode(legacy.AvatarMode mode) {
    return switch (mode) {
      legacy.AvatarMode.looksLikeMe => AvatarV2Mode.looksLikeMe,
      legacy.AvatarMode.inspiredByMe => AvatarV2Mode.inspiredByMe,
      legacy.AvatarMode.privateAbstract => AvatarV2Mode.privateAbstract,
    };
  }

  static AvatarV2RealismLevel _realism(legacy.AvatarRealismLevel realism) {
    return switch (realism) {
      legacy.AvatarRealismLevel.soft => AvatarV2RealismLevel.soft,
      legacy.AvatarRealismLevel.semiRealistic => AvatarV2RealismLevel.semiRealistic,
      legacy.AvatarRealismLevel.ultraRealistic => AvatarV2RealismLevel.realistic,
    };
  }

  static AvatarV2LightingStyle _lighting(legacy.AvatarLightingStyle lighting) {
    return switch (lighting) {
      legacy.AvatarLightingStyle.studio => AvatarV2LightingStyle.softStudio,
      legacy.AvatarLightingStyle.softNatural => AvatarV2LightingStyle.naturalDaylight,
      legacy.AvatarLightingStyle.neon => AvatarV2LightingStyle.dramatic,
      legacy.AvatarLightingStyle.warm => AvatarV2LightingStyle.warmRoom,
      legacy.AvatarLightingStyle.cool => AvatarV2LightingStyle.flatAccessible,
    };
  }

  static AvatarV2CameraStyle _camera(legacy.AvatarCameraStyle camera) {
    return switch (camera) {
      legacy.AvatarCameraStyle.headshot => AvatarV2CameraStyle.headOnly,
      legacy.AvatarCameraStyle.shoulders => AvatarV2CameraStyle.headAndShoulders,
      legacy.AvatarCameraStyle.bust => AvatarV2CameraStyle.upperBody,
    };
  }

  static AvatarV2AgePresentation _age(legacy.AvatarAgePresentation age) {
    return switch (age) {
      legacy.AvatarAgePresentation.child => AvatarV2AgePresentation.child,
      legacy.AvatarAgePresentation.preTeen => AvatarV2AgePresentation.preTeen,
      legacy.AvatarAgePresentation.teen => AvatarV2AgePresentation.teen,
      legacy.AvatarAgePresentation.youngAdult => AvatarV2AgePresentation.youngAdult,
      legacy.AvatarAgePresentation.adult => AvatarV2AgePresentation.adult,
      legacy.AvatarAgePresentation.olderAdult => AvatarV2AgePresentation.olderAdult,
    };
  }

  static AvatarV2FaceShape _faceShape(legacy.AvatarFaceShape shape) {
    return switch (shape) {
      legacy.AvatarFaceShape.oval => AvatarV2FaceShape.oval,
      legacy.AvatarFaceShape.round => AvatarV2FaceShape.round,
      legacy.AvatarFaceShape.square => AvatarV2FaceShape.square,
      legacy.AvatarFaceShape.heart => AvatarV2FaceShape.heart,
      legacy.AvatarFaceShape.long => AvatarV2FaceShape.long,
    };
  }

  static AvatarV2Expression _expression(legacy.AvatarExpression expression) {
    return switch (expression) {
      legacy.AvatarExpression.neutral => AvatarV2Expression.neutral,
      legacy.AvatarExpression.calm => AvatarV2Expression.calm,
      legacy.AvatarExpression.happy => AvatarV2Expression.happy,
      legacy.AvatarExpression.focused => AvatarV2Expression.focused,
      legacy.AvatarExpression.proud => AvatarV2Expression.proud,
      legacy.AvatarExpression.tired => AvatarV2Expression.calm,
      legacy.AvatarExpression.overwhelmed => AvatarV2Expression.focused,
    };
  }

  static AvatarV2SkinTone _skinTone(Object color) {
    final value = color is int ? color : (color as dynamic).value as int;
    const thresholds = <int, AvatarV2SkinTone>{
      0xFFFFDBB5: AvatarV2SkinTone.veryLight,
      0xFFEFC29A: AvatarV2SkinTone.light,
      0xFFDFA878: AvatarV2SkinTone.medium,
      0xFFC68642: AvatarV2SkinTone.olive,
      0xFFB87952: AvatarV2SkinTone.tan,
      0xFF8D5524: AvatarV2SkinTone.brown,
      0xFF5C3424: AvatarV2SkinTone.deepBrown,
      0xFF3B2219: AvatarV2SkinTone.veryDeep,
    };
    return thresholds[value] ?? AvatarV2SkinTone.medium;
  }

  static AvatarV2HairTexture _hairTexture(legacy.AvatarHairType type) {
    return switch (type) {
      legacy.AvatarHairType.none => AvatarV2HairTexture.bald,
      legacy.AvatarHairType.straight => AvatarV2HairTexture.straight,
      legacy.AvatarHairType.wavy => AvatarV2HairTexture.wavy,
      legacy.AvatarHairType.curly => AvatarV2HairTexture.curly,
      legacy.AvatarHairType.coily => AvatarV2HairTexture.coily,
      legacy.AvatarHairType.afro => AvatarV2HairTexture.afro,
      legacy.AvatarHairType.locs => AvatarV2HairTexture.locs,
      legacy.AvatarHairType.braids => AvatarV2HairTexture.braids,
      legacy.AvatarHairType.twists => AvatarV2HairTexture.twists,
      legacy.AvatarHairType.shaved => AvatarV2HairTexture.shaved,
      legacy.AvatarHairType.covered => AvatarV2HairTexture.covered,
    };
  }

  static AvatarV2HairStyle _hairStyle(
    legacy.AvatarHairType type,
    legacy.AvatarHairStyle style,
  ) {
    if (type == legacy.AvatarHairType.afro) {
      return style == legacy.AvatarHairStyle.curlyAfroWithSidePart
          ? AvatarV2HairStyle.sidePartAfro
          : AvatarV2HairStyle.fullAfro;
    }
    if (type == legacy.AvatarHairType.coily) return AvatarV2HairStyle.taperedCoils;
    if (type == legacy.AvatarHairType.locs) return AvatarV2HairStyle.shoulderLocs;
    if (type == legacy.AvatarHairType.braids) return AvatarV2HairStyle.boxBraids;
    if (type == legacy.AvatarHairType.twists) return AvatarV2HairStyle.longTwists;
    if (type == legacy.AvatarHairType.shaved) return AvatarV2HairStyle.buzzCut;
    if (type == legacy.AvatarHairType.covered) return AvatarV2HairStyle.headwrap;

    return switch (style) {
      legacy.AvatarHairStyle.shortCurls => AvatarV2HairStyle.shortCurls,
      legacy.AvatarHairStyle.shoulderLengthCurls => AvatarV2HairStyle.shoulderCurls,
      legacy.AvatarHairStyle.fullCurlyAfro => AvatarV2HairStyle.fullAfro,
      legacy.AvatarHairStyle.curlyAfroWithSidePart => AvatarV2HairStyle.sidePartAfro,
      legacy.AvatarHairStyle.longRinglets => AvatarV2HairStyle.longCurls,
      legacy.AvatarHairStyle.locs => AvatarV2HairStyle.shoulderLocs,
      legacy.AvatarHairStyle.twists => AvatarV2HairStyle.longTwists,
      legacy.AvatarHairStyle.braids => AvatarV2HairStyle.boxBraids,
      legacy.AvatarHairStyle.protectiveStyle => AvatarV2HairStyle.cornrows,
      legacy.AvatarHairStyle.natural => AvatarV2HairStyle.shortWaves,
    };
  }

  static AvatarV2HairLength _hairLength(
    legacy.AvatarHairLength length,
    AvatarV2HairTexture texture,
    AvatarV2HairStyle style,
  ) {
    if (style == AvatarV2HairStyle.fullAfro ||
        style == AvatarV2HairStyle.sidePartAfro ||
        style == AvatarV2HairStyle.taperedAfro ||
        style == AvatarV2HairStyle.taperedCoils) {
      return AvatarV2HairLength.medium;
    }
    return switch (length) {
      legacy.AvatarHairLength.bald => AvatarV2HairLength.bald,
      legacy.AvatarHairLength.short => AvatarV2HairLength.short,
      legacy.AvatarHairLength.medium => AvatarV2HairLength.medium,
      legacy.AvatarHairLength.long => AvatarV2HairLength.long,
    };
  }

  static AvatarV2HairVolume _hairVolume(
    AvatarV2HairTexture texture,
    AvatarV2HairStyle style,
  ) {
    if (texture == AvatarV2HairTexture.afro) return AvatarV2HairVolume.halo;
    if (texture == AvatarV2HairTexture.coily) return AvatarV2HairVolume.high;
    if (texture == AvatarV2HairTexture.curly) return AvatarV2HairVolume.high;
    if (style == AvatarV2HairStyle.longCurls) return AvatarV2HairVolume.high;
    return AvatarV2HairVolume.medium;
  }

  static AvatarV2FrontStrandPolicy _frontStrandPolicy(
    AvatarV2HairTexture texture,
    AvatarV2HairStyle style,
  ) {
    if (texture == AvatarV2HairTexture.locs ||
        texture == AvatarV2HairTexture.braids ||
        texture == AvatarV2HairTexture.twists) {
      return AvatarV2FrontStrandPolicy.sideOnly;
    }
    if (texture == AvatarV2HairTexture.afro ||
        texture == AvatarV2HairTexture.coily) {
      return AvatarV2FrontStrandPolicy.noFaceOverlap;
    }
    return AvatarV2FrontStrandPolicy.sideOnly;
  }

  static AvatarV2HairColour _hairColour(Object color) {
    final value = color is int ? color : (color as dynamic).value as int;
    if (value == 0xFF111827 || value == 0xFF2A1710) {
      return AvatarV2HairColour.black;
    }
    if (value == 0xFFD1D5DB) return AvatarV2HairColour.grey;
    if (value == 0xFFF8FAFC) return AvatarV2HairColour.white;
    if (value == 0xFFEAB308) return AvatarV2HairColour.blonde;
    if (value == 0xFFC2410C || value == 0xFFB45309) {
      return AvatarV2HairColour.ginger;
    }
    if (value == 0xFF7C3AED || value == 0xFF06B6D4 || value == 0xFFEC4899) {
      return AvatarV2HairColour.dyed;
    }
    return AvatarV2HairColour.brown;
  }

  static AvatarV2FacialHairType _facialHairType(legacy.AvatarFacialHair value) {
    return switch (value) {
      legacy.AvatarFacialHair.none => AvatarV2FacialHairType.none,
      legacy.AvatarFacialHair.lightStubble => AvatarV2FacialHairType.stubble,
      legacy.AvatarFacialHair.moustache => AvatarV2FacialHairType.moustache,
      legacy.AvatarFacialHair.goatee => AvatarV2FacialHairType.goatee,
      legacy.AvatarFacialHair.shortBeard => AvatarV2FacialHairType.shortBeard,
      legacy.AvatarFacialHair.fullBeard => AvatarV2FacialHairType.fullBeard,
    };
  }

  static AvatarV2BodyFrame _body(legacy.AvatarBodyPresentation body) {
    return switch (body) {
      legacy.AvatarBodyPresentation.petite => AvatarV2BodyFrame.petite,
      legacy.AvatarBodyPresentation.slim => AvatarV2BodyFrame.slim,
      legacy.AvatarBodyPresentation.average => AvatarV2BodyFrame.average,
      legacy.AvatarBodyPresentation.broad => AvatarV2BodyFrame.broad,
      legacy.AvatarBodyPresentation.larger => AvatarV2BodyFrame.larger,
      legacy.AvatarBodyPresentation.muscular => AvatarV2BodyFrame.muscular,
      legacy.AvatarBodyPresentation.seated => AvatarV2BodyFrame.average,
    };
  }

  static AvatarV2ShoulderWidth _shoulder(legacy.AvatarBodyPresentation body) {
    return switch (body) {
      legacy.AvatarBodyPresentation.petite ||
      legacy.AvatarBodyPresentation.slim => AvatarV2ShoulderWidth.narrow,
      legacy.AvatarBodyPresentation.broad ||
      legacy.AvatarBodyPresentation.larger ||
      legacy.AvatarBodyPresentation.muscular => AvatarV2ShoulderWidth.broad,
      _ => AvatarV2ShoulderWidth.medium,
    };
  }
}
