import 'package:flutter/material.dart';

import '../avatar/avatar_enums.dart' as legacy_enum;
import '../avatar/user_avatar_profile.dart' as legacy_profile;
import '../user_avatar/user_avatar_profile.dart' as string_profile;
import 'avatar_v3_enums.dart';
import 'avatar_v3_options.dart';
import 'avatar_v3_profile.dart';

class AvatarV3Migration {
  const AvatarV3Migration._();

  static AvatarV3Profile fromAny(Object? value) {
    if (value is AvatarV3Profile) return AvatarV3Options.normalize(value);
    if (value is legacy_profile.UserAvatarProfile) {
      return fromLegacyProfile(value);
    }
    if (value is string_profile.UserAvatarProfile) {
      return fromStringProfile(value);
    }
    return AvatarV3Options.normalize(defaultReferenceProfile);
  }

  static AvatarV3Profile fromLegacyProfile(legacy_profile.UserAvatarProfile value) {
    if (_isLegacyStarterLikeProfile(value)) {
      return AvatarV3Options.normalize(defaultReferenceProfile);
    }

    final type = _legacyHairType(value.hairType);
    final style = _defaultStyleFor(type);
    final age = _legacyAge(value.agePresentation);

    return AvatarV3Options.normalize(
      AvatarV3Profile(
        mode: switch (value.mode) {
          legacy_enum.AvatarMode.looksLikeMe => AvatarV3Mode.looksLikeMe,
          legacy_enum.AvatarMode.privateAbstract => AvatarV3Mode.privateAbstract,
          legacy_enum.AvatarMode.inspiredByMe => AvatarV3Mode.inspiredByMe,
        },
        camera: switch (value.cameraStyle) {
          legacy_enum.AvatarCameraStyle.headshot => AvatarV3Camera.headshot,
          legacy_enum.AvatarCameraStyle.shoulders => AvatarV3Camera.bust,
          legacy_enum.AvatarCameraStyle.bust => AvatarV3Camera.halfBody,
        },
        agePresentation: age,
        head: AvatarV3HeadProfile(
          shape: switch (value.faceShape) {
            legacy_enum.AvatarFaceShape.round => AvatarV3HeadShape.round,
            legacy_enum.AvatarFaceShape.square => AvatarV3HeadShape.square,
            legacy_enum.AvatarFaceShape.heart => AvatarV3HeadShape.heart,
            legacy_enum.AvatarFaceShape.long => AvatarV3HeadShape.long,
            legacy_enum.AvatarFaceShape.oval => AvatarV3HeadShape.oval,
          },
        ),
        face: const AvatarV3FaceProfile(shape: AvatarV3FaceShape.softRound),
        skin: AvatarV3SkinProfile(
          tone: _skinToneFromColor(value.skinTone),
          freckles: value.skinDetail == legacy_enum.AvatarSkinDetail.freckles
              ? const AvatarV3PlacementDetail(
                  amount: AvatarV3DetailAmount.medium,
                  placements: <AvatarV3DetailPlacement>[
                    AvatarV3DetailPlacement.noseAndCheeks,
                  ],
                )
              : const AvatarV3PlacementDetail(),
        ),
        hair: AvatarV3HairProfile(
          type: type,
          style: style,
          length: _legacyHairLength(value.hairLength),
          volume: type == AvatarV3HairType.ringletAfro ||
                  type == AvatarV3HairType.afro
              ? AvatarV3HairVolume.halo
              : AvatarV3HairVolume.medium,
          frontPolicy: AvatarV3Options.defaultFrontPolicyFor(type, style),
          colour: _hairColourFromColor(value.hairColor),
        ),
        facialHair: const AvatarV3FacialHairProfile(),
        body: AvatarV3BodyProfile(
          presentation: switch (value.bodyPresentation) {
            legacy_enum.AvatarBodyPresentation.petite =>
              AvatarV3BodyPresentation.petite,
            legacy_enum.AvatarBodyPresentation.slim =>
              AvatarV3BodyPresentation.slim,
            legacy_enum.AvatarBodyPresentation.broad =>
              AvatarV3BodyPresentation.broad,
            legacy_enum.AvatarBodyPresentation.larger =>
              AvatarV3BodyPresentation.larger,
            legacy_enum.AvatarBodyPresentation.muscular =>
              AvatarV3BodyPresentation.muscular,
            _ => AvatarV3BodyPresentation.average,
          },
        ),
        accessories: AvatarV3AccessoryProfile(
          items: value.accessibilityItems
              .map(_legacyAccessory)
              .whereType<AvatarV3Accessory>()
              .toList(),
        ),
      ),
    );
  }

  static AvatarV3Profile fromStringProfile(string_profile.UserAvatarProfile value) {
    if (_isStringStarterLikeProfile(value)) {
      return AvatarV3Options.normalize(defaultReferenceProfile);
    }

    final type = _stringHairType(value.hairType);
    final style = _stringHairStyle(type, value.hairStyle);

    return AvatarV3Options.normalize(
      AvatarV3Profile(
        mode: switch (value.normalizedAvatarType) {
          string_profile.UserAvatarProfile.avatarTypeLooksLikeMe =>
            AvatarV3Mode.looksLikeMe,
          string_profile.UserAvatarProfile.avatarTypePrivateAbstract =>
            AvatarV3Mode.privateAbstract,
          _ => AvatarV3Mode.inspiredByMe,
        },
        agePresentation: _stringAge(value.agePresentation),
        skin: AvatarV3SkinProfile(tone: _stringSkinTone(value.skinTone)),
        hair: AvatarV3HairProfile(
          type: type,
          style: style,
          length: AvatarV3Options.defaultHairLengthFor(type, style),
          volume: type == AvatarV3HairType.ringletAfro
              ? AvatarV3HairVolume.halo
              : AvatarV3HairVolume.medium,
          frontPolicy: AvatarV3Options.defaultFrontPolicyFor(type, style),
          colour: _stringHairColour(value.hairColor),
        ),
        body: AvatarV3BodyProfile(
          presentation: _stringBody(value.bodyShape),
        ),
        accessories: AvatarV3AccessoryProfile(
          items: value.accessibilityItems
              .map(_stringAccessory)
              .whereType<AvatarV3Accessory>()
              .toList(),
        ),
      ),
    );
  }

  static const AvatarV3Profile defaultReferenceProfile = AvatarV3Profile(
    camera: AvatarV3Camera.bust,
    agePresentation: AvatarV3AgePresentation.adult,
    skin: AvatarV3SkinProfile(
      tone: AvatarV3SkinTone.tan,
      undertone: AvatarV3SkinUndertone.warm,
      freckles: AvatarV3PlacementDetail(
        amount: AvatarV3DetailAmount.medium,
        placements: <AvatarV3DetailPlacement>[
          AvatarV3DetailPlacement.noseAndCheeks,
        ],
      ),
    ),
    hair: AvatarV3HairProfile(
      type: AvatarV3HairType.ringletAfro,
      style: AvatarV3HairStyle.longRingletAfro,
      length: AvatarV3HairLength.long,
      volume: AvatarV3HairVolume.halo,
      frontPolicy: AvatarV3HairFrontPolicy.noFaceOverlap,
      colour: AvatarV3HairColour.copper,
    ),
    clothing: AvatarV3ClothingProfile(
      top: AvatarV3ClothingTop.sleevelessTop,
      bottom: AvatarV3ClothingBottom.jeans,
      shoes: AvatarV3Shoes.trainers,
    ),
  );

  static bool _isLegacyStarterLikeProfile(legacy_profile.UserAvatarProfile value) {
    // Current home/default legacy profile resolves to a generic curly-medium
    // placeholder. That placeholder must not become a bald/simple V3 avatar.
    // If the old profile has no image reference and uses the old generic default,
    // promote it to the V3 starter profile.
    return value.generatedImageUrl == null &&
        value.localImagePath == null &&
        value.mode == legacy_enum.AvatarMode.inspiredByMe &&
        value.hairType.name == 'curly' &&
        value.hairLength == legacy_enum.AvatarHairLength.medium &&
        value.skinDetail == legacy_enum.AvatarSkinDetail.none;
  }

  static bool _isStringStarterLikeProfile(string_profile.UserAvatarProfile value) {
    return (value.hairType == 'curly' || value.hairType == 'wavy') &&
        (value.hairStyle.isEmpty ||
            value.hairStyle == 'medium_wavy' ||
            value.hairStyle == 'mediumWavy' ||
            value.hairStyle == 'short');
  }

  static AvatarV3HairType _legacyHairType(legacy_enum.AvatarHairType type) {
    final name = type.name;

    if (name == 'none') return AvatarV3HairType.bald;
    if (name == 'straight') return AvatarV3HairType.straight;
    if (name == 'wavy') return AvatarV3HairType.wavy;
    if (name == 'curly') return AvatarV3HairType.curly;
    if (name == 'coily') return AvatarV3HairType.coily;
    if (name == 'afro' ||
        name == 'curlyAfro' ||
        name == 'curly_afro' ||
        name == 'voluminousCurly' ||
        name == 'voluminous_curly') {
      return AvatarV3HairType.ringletAfro;
    }
    if (name == 'locs') return AvatarV3HairType.locs;
    if (name == 'braids') return AvatarV3HairType.braids;
    if (name == 'twists') return AvatarV3HairType.twists;
    if (name == 'fade' || name == 'shaved') return AvatarV3HairType.shaved;
    if (name == 'covered') return AvatarV3HairType.covered;
    if (name == 'frizzy') return AvatarV3HairType.frizzy;
    return AvatarV3HairType.wavy;
  }

  static AvatarV3HairStyle _defaultStyleFor(AvatarV3HairType type) {
    if (type == AvatarV3HairType.ringletAfro) {
      return AvatarV3HairStyle.longRingletAfro;
    }
    return AvatarV3Options.defaultHairStyleFor(type);
  }

  static AvatarV3AgePresentation _legacyAge(legacy_enum.AvatarAgePresentation age) {
    return switch (age) {
      legacy_enum.AvatarAgePresentation.child => AvatarV3AgePresentation.child,
      legacy_enum.AvatarAgePresentation.preTeen => AvatarV3AgePresentation.preTeen,
      legacy_enum.AvatarAgePresentation.teen => AvatarV3AgePresentation.teen,
      legacy_enum.AvatarAgePresentation.youngAdult =>
        AvatarV3AgePresentation.youngAdult,
      legacy_enum.AvatarAgePresentation.olderAdult =>
        AvatarV3AgePresentation.olderAdult,
      legacy_enum.AvatarAgePresentation.adult => AvatarV3AgePresentation.adult,
    };
  }

  static AvatarV3SkinTone _skinToneFromColor(Color color) {
    final value = color.value;
    final r = (value >> 16) & 0xff;
    final g = (value >> 8) & 0xff;
    final b = value & 0xff;
    final luminance = (0.2126 * r + 0.7152 * g + 0.0722 * b);

    if (luminance >= 230) return AvatarV3SkinTone.veryLight;
    if (luminance >= 205) return AvatarV3SkinTone.light;
    if (luminance >= 170) return AvatarV3SkinTone.medium;
    if (luminance >= 140) return AvatarV3SkinTone.tan;
    if (luminance >= 105) return AvatarV3SkinTone.brown;
    if (luminance >= 70) return AvatarV3SkinTone.deepBrown;
    return AvatarV3SkinTone.veryDeep;
  }

  static AvatarV3HairLength _legacyHairLength(legacy_enum.AvatarHairLength length) {
    return switch (length) {
      legacy_enum.AvatarHairLength.bald => AvatarV3HairLength.none,
      legacy_enum.AvatarHairLength.short => AvatarV3HairLength.short,
      legacy_enum.AvatarHairLength.medium => AvatarV3HairLength.medium,
      legacy_enum.AvatarHairLength.long => AvatarV3HairLength.long,
    };
  }

  static AvatarV3HairColour _hairColourFromColor(Color color) {
    final value = color.value;
    if (value == 0xFF111827 || value == 0xFF2A1710 || value == 0xFF000000) {
      return AvatarV3HairColour.black;
    }
    if (value == 0xFFC2410C || value == 0xFFB45309 || value == 0xFFD97706) {
      return AvatarV3HairColour.copper;
    }
    if (value == 0xFFEAB308 || value == 0xFFFACC15) return AvatarV3HairColour.blonde;
    if (value == 0xFFD1D5DB || value == 0xFF9CA3AF) return AvatarV3HairColour.grey;
    if (value == 0xFFF8FAFC || value == 0xFFFFFFFF) return AvatarV3HairColour.white;
    return AvatarV3HairColour.brown;
  }

  static AvatarV3Accessory? _legacyAccessory(legacy_enum.AvatarAccessibilityItem item) {
    return switch (item) {
      legacy_enum.AvatarAccessibilityItem.glasses => AvatarV3Accessory.glasses,
      legacy_enum.AvatarAccessibilityItem.hearingAidLeft =>
        AvatarV3Accessory.hearingAidLeft,
      legacy_enum.AvatarAccessibilityItem.hearingAidRight =>
        AvatarV3Accessory.hearingAidRight,
      legacy_enum.AvatarAccessibilityItem.cochlearImplant =>
        AvatarV3Accessory.cochlearImplant,
      legacy_enum.AvatarAccessibilityItem.sensoryHeadphones =>
        AvatarV3Accessory.sensoryHeadphones,
      legacy_enum.AvatarAccessibilityItem.medicalPatch =>
        AvatarV3Accessory.medicalPatch,
      legacy_enum.AvatarAccessibilityItem.glucoseMonitor =>
        AvatarV3Accessory.glucoseMonitor,
      legacy_enum.AvatarAccessibilityItem.prostheticArmIndicator => null,
    };
  }

  static AvatarV3HairType _stringHairType(String value) {
    return switch (value) {
      'bald' => AvatarV3HairType.bald,
      'shaved' => AvatarV3HairType.shaved,
      'straight' => AvatarV3HairType.straight,
      'wavy' => AvatarV3HairType.wavy,
      'curly' => AvatarV3HairType.curly,
      'coily' => AvatarV3HairType.coily,
      'afro' || 'curly_afro' || 'afro_textured' => AvatarV3HairType.ringletAfro,
      'braids' => AvatarV3HairType.braids,
      'locs' => AvatarV3HairType.locs,
      'twists' => AvatarV3HairType.twists,
      'covered' => AvatarV3HairType.covered,
      'frizzy' => AvatarV3HairType.frizzy,
      _ => AvatarV3HairType.wavy,
    };
  }

  static AvatarV3HairStyle _stringHairStyle(AvatarV3HairType type, String value) {
    if (type == AvatarV3HairType.ringletAfro) {
      return value == 'side_part_afro'
          ? AvatarV3HairStyle.sidePartAfro
          : AvatarV3HairStyle.longRingletAfro;
    }
    return AvatarV3Options.defaultHairStyleFor(type);
  }

  static AvatarV3AgePresentation _stringAge(String value) {
    return switch (value) {
      'child' => AvatarV3AgePresentation.child,
      'pre_teen' || 'preTeen' => AvatarV3AgePresentation.preTeen,
      'teen' => AvatarV3AgePresentation.teen,
      'young_adult' || 'youngAdult' => AvatarV3AgePresentation.youngAdult,
      'older_adult' || 'olderAdult' => AvatarV3AgePresentation.olderAdult,
      _ => AvatarV3AgePresentation.adult,
    };
  }

  static AvatarV3SkinTone _stringSkinTone(String value) {
    return switch (value) {
      'very_light' || 'veryLight' => AvatarV3SkinTone.veryLight,
      'light' => AvatarV3SkinTone.light,
      'olive' => AvatarV3SkinTone.olive,
      'tan' => AvatarV3SkinTone.tan,
      'brown' => AvatarV3SkinTone.brown,
      'deep_brown' || 'deepBrown' => AvatarV3SkinTone.deepBrown,
      'very_deep' || 'veryDeep' => AvatarV3SkinTone.veryDeep,
      _ => AvatarV3SkinTone.medium,
    };
  }

  static AvatarV3HairColour _stringHairColour(String value) {
    return switch (value) {
      'black' => AvatarV3HairColour.black,
      'dark_brown' || 'darkBrown' => AvatarV3HairColour.darkBrown,
      'light_brown' || 'lightBrown' => AvatarV3HairColour.lightBrown,
      'blonde' => AvatarV3HairColour.blonde,
      'ginger' => AvatarV3HairColour.ginger,
      'auburn' => AvatarV3HairColour.auburn,
      'copper' => AvatarV3HairColour.copper,
      'grey' => AvatarV3HairColour.grey,
      'white' => AvatarV3HairColour.white,
      'dyed' => AvatarV3HairColour.dyed,
      _ => AvatarV3HairColour.brown,
    };
  }

  static AvatarV3BodyPresentation _stringBody(String value) {
    return switch (value) {
      'petite' => AvatarV3BodyPresentation.petite,
      'slim' => AvatarV3BodyPresentation.slim,
      'broad' => AvatarV3BodyPresentation.broad,
      'larger' || 'larger_body' => AvatarV3BodyPresentation.larger,
      'muscular' => AvatarV3BodyPresentation.muscular,
      _ => AvatarV3BodyPresentation.average,
    };
  }

  static AvatarV3Accessory? _stringAccessory(String value) {
    return switch (value) {
      'glasses' => AvatarV3Accessory.glasses,
      'sunglasses' => AvatarV3Accessory.sunglasses,
      'hearing_aid_left' || 'hearingAidLeft' => AvatarV3Accessory.hearingAidLeft,
      'hearing_aid_right' || 'hearingAidRight' =>
        AvatarV3Accessory.hearingAidRight,
      'cochlear_implant' || 'cochlearImplant' =>
        AvatarV3Accessory.cochlearImplant,
      'sensory_headphones' || 'sensoryHeadphones' =>
        AvatarV3Accessory.sensoryHeadphones,
      'headscarf' => AvatarV3Accessory.headscarf,
      'earrings' => AvatarV3Accessory.earrings,
      'medical_patch' || 'medicalPatch' => AvatarV3Accessory.medicalPatch,
      'glucose_monitor' || 'glucoseMonitor' => AvatarV3Accessory.glucoseMonitor,
      _ => null,
    };
  }
}
