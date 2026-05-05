import 'package:flutter/material.dart';

import 'avatar_enums.dart';
import 'user_avatar_profile.dart';

class RealisticAvatarPromptBuilder {
  const RealisticAvatarPromptBuilder._();

  static String build(UserAvatarProfile profile) {
    if (profile.mode == AvatarMode.privateAbstract ||
        profile.renderMode == AvatarRenderMode.abstract) {
      return _abstractPrompt(profile);
    }

    final buffer = StringBuffer()
      ..write('A warm semi-realistic head-and-shoulders digital portrait ')
      ..write(_agePhrase(profile.agePresentation))
      ..write('with ${_skinToneText(profile)} skin, ')
      ..write(_hairPhrase(profile))
      ..write('a ${profile.faceShape.label.toLowerCase()} face shape, ')
      ..write('${profile.expression.label.toLowerCase()} expression, ');

    final skinDetail = _skinDetailPhrase(profile.skinDetail);
    if (skinDetail.isNotEmpty) buffer.write('$skinDetail, ');

    final facialHair = _facialHairPhrase(profile);
    if (facialHair.isNotEmpty) buffer.write('$facialHair, ');

    if (profile.accessibilityItems.isNotEmpty) {
      buffer
        ..write('including ')
        ..write(profile.accessibilityItems.map(_accessibilityPhrase).join(', '))
        ..write(', ');
    }

    if (profile.culturalItem != AvatarCulturalItem.none) {
      buffer.write('wearing ${_culturalPhrase(profile.culturalItem)}, ');
    }

    buffer
      ..write('${profile.lightingStyle.label.toLowerCase()} lighting, ')
      ..write('${profile.cameraStyle.label.toLowerCase()} framing, ')
      ..write('realistic Apple and Meta inspired avatar style, ')
      ..write('natural proportions, dignified, friendly, ')
      ..write('human-like but still an app avatar, detailed but not uncanny, clean soft background, ')
      ..write('high quality app profile avatar, consistent portrait lighting.');

    return buffer.toString();
  }

  static String negativePrompt([UserAvatarProfile? profile]) {
    final items = <String>[
      'Lego style',
      'blocky toy avatar',
      'plastic toy figure',
      'caricature',
      'exaggerated features',
      'uncanny face',
      'distorted face',
      'extra limbs',
      'deformed hands',
      'medical stereotype',
      'offensive stereotype',
      'childish adult',
      'sexualised',
      'glamour photo',
      'low quality',
      'blurry',
      'messy background',
      'text',
      'watermark',
    ];

    final cleanShaven = profile == null ||
        profile.facialHair == AvatarFacialHair.none ||
        profile.agePresentation == AvatarAgePresentation.child ||
        profile.agePresentation == AvatarAgePresentation.preTeen;

    if (cleanShaven) {
      items.addAll(<String>[
        'beard',
        'moustache',
        'mustache',
        'stubble',
        'facial hair',
        'hair on chin',
        'hair on jaw',
        'hair across mouth',
      ]);
    }

    if (profile != null &&
        (profile.hairType == AvatarHairType.curly ||
            profile.hairType == AvatarHairType.coily ||
            profile.hairType == AvatarHairType.afro)) {
      items.addAll(<String>[
        'curls on chin',
        'curls on jaw',
        'curls under mouth',
        'afro beard',
        'hair mistaken for beard',
      ]);
    }

    return items.join(', ');
  }

  static Map<String, dynamic> buildPayload(UserAvatarProfile profile) {
    return <String, dynamic>{
      'prompt': build(profile),
      'negativePrompt': negativePrompt(profile),
      'size': '1024x1024',
      'style': profile.realismLevel.name,
      'safety': <String, dynamic>{
        'noFaceUploadRequired': true,
        'noBiometricIdentification': true,
        'minorSafe': profile.agePresentation == AvatarAgePresentation.child ||
            profile.agePresentation == AvatarAgePresentation.preTeen ||
            profile.agePresentation == AvatarAgePresentation.teen,
      },
      'profile': <String, dynamic>{
        'mode': profile.mode.name,
        'renderMode': profile.renderMode.name,
        'realismLevel': profile.realismLevel.name,
        'lightingStyle': profile.lightingStyle.name,
        'cameraStyle': profile.cameraStyle.name,
        'agePresentation': profile.agePresentation.name,
        'bodyPresentation': profile.bodyPresentation.name,
        'hairType': profile.hairType.name,
        'hairLength': profile.hairLength.name,
        'hairStyle': profile.hairStyle.name,
        'hairColor': profile.hairColor.value,
        'facialHair': profile.facialHair.name,
        'faceShape': profile.faceShape.name,
        'expression': profile.expression.name,
        'skinDetail': profile.skinDetail.name,
        'culturalItem': profile.culturalItem.name,
        'accessibilityItems':
            profile.accessibilityItems.map((item) => item.name).toList(),
      },
    };
  }

  static String _agePhrase(AvatarAgePresentation value) {
    switch (value) {
      case AvatarAgePresentation.child:
        return 'of a child ';
      case AvatarAgePresentation.preTeen:
        return 'of a pre-teen ';
      case AvatarAgePresentation.teen:
        return 'of a teenager ';
      case AvatarAgePresentation.youngAdult:
        return 'of a young adult ';
      case AvatarAgePresentation.adult:
        return 'of an adult ';
      case AvatarAgePresentation.olderAdult:
        return 'of an older adult ';
    }
  }

  static String _hairPhrase(UserAvatarProfile profile) {
    if (profile.hairType == AvatarHairType.none ||
        profile.hairLength == AvatarHairLength.bald) {
      return 'a bald or closely shaved head, ';
    }
    if (profile.hairType == AvatarHairType.covered) {
      return 'hair covered respectfully, ';
    }

    final colorText = _hairColorText(profile.hairColor);

    switch (profile.hairStyle) {
      case AvatarHairStyle.fullCurlyAfro:
        return '$colorText full curly afro hair, dense natural curls, rounded crown volume, '
            'hair only on scalp and around shoulders, clean visible face, ';
      case AvatarHairStyle.curlyAfroWithSidePart:
        return '$colorText curly afro with a soft side part, dense natural ringlets, '
            'rounded crown volume like a modern Apple Meta style avatar, '
            'hair only on scalp and around shoulders, clean visible face, ';
      case AvatarHairStyle.shoulderLengthCurls:
        return '$colorText shoulder-length curly hair with defined ringlets falling at the sides, '
            'no curls on chin or jaw, ';
      case AvatarHairStyle.longRinglets:
        return '$colorText long defined ringlets falling at the sides of the head and shoulders, '
            'no curls on chin or jaw, ';
      case AvatarHairStyle.shortCurls:
        return '$colorText short curly hair with defined curls on the crown, clean visible face, ';
      case AvatarHairStyle.locs:
      case AvatarHairStyle.twists:
      case AvatarHairStyle.braids:
      case AvatarHairStyle.protectiveStyle:
      case AvatarHairStyle.natural:
        break;
    }

    switch (profile.hairType) {
      case AvatarHairType.afro:
        return '$colorText voluminous curly afro hair, dense natural ringlets, '
            'hair only on scalp and around shoulders, clean visible face, ';
      case AvatarHairType.coily:
        return '$colorText coily natural hair with dense defined curls, '
            'hair only on scalp and around shoulders, clean visible face, ';
      case AvatarHairType.curly:
        return '$colorText ${profile.hairLength.label.toLowerCase()} curly hair '
            'with defined ringlets framing the head, no curls on chin or jaw, ';
      case AvatarHairType.locs:
      case AvatarHairType.braids:
      case AvatarHairType.twists:
        return '$colorText ${profile.hairLength.label.toLowerCase()} '
            '${profile.hairType.label.toLowerCase()} hair, ';
      case AvatarHairType.straight:
      case AvatarHairType.wavy:
      case AvatarHairType.shaved:
        return '$colorText ${profile.hairLength.label.toLowerCase()} '
            '${profile.hairType.label.toLowerCase()} hair, ';
      case AvatarHairType.none:
      case AvatarHairType.covered:
        return '';
    }
  }

  static String _facialHairPhrase(UserAvatarProfile profile) {
    if (profile.agePresentation == AvatarAgePresentation.child ||
        profile.agePresentation == AvatarAgePresentation.preTeen ||
        profile.facialHair == AvatarFacialHair.none) {
      return 'clean-shaven face, no beard, no moustache, no stubble';
    }

    return switch (profile.facialHair) {
      AvatarFacialHair.lightStubble => 'light facial stubble',
      AvatarFacialHair.moustache => 'a neat moustache',
      AvatarFacialHair.goatee => 'a neat goatee',
      AvatarFacialHair.shortBeard => 'a short well-kept beard',
      AvatarFacialHair.fullBeard => 'a full well-kept beard',
      AvatarFacialHair.none => '',
    };
  }

  static String _hairColorText(Color color) {
    final value = color.value;
    if (value == 0xFFA04000 || value == 0xFFB45309) return 'auburn';
    if (value == 0xFFC2410C || value == 0xFFD97706) return 'copper';
    if (value == 0xFF8B4513 || value == 0xFF5C4033) return 'brown';
    if (value == 0xFFEAB308) return 'blonde';
    if (value == 0xFFD1D5DB || value == 0xFFF8FAFC) return 'light';
    return 'dark';
  }

  static String _skinToneText(UserAvatarProfile profile) {
    final value = profile.skinTone.value;
    if (value == 0xFFFFDBB5) return 'very light';
    if (value == 0xFFEFC29A) return 'light';
    if (value == 0xFFDFA878) return 'warm light brown';
    if (value == 0xFFC68642) return 'medium brown';
    if (value == 0xFFB87952) return 'warm brown';
    if (value == 0xFF8D5524) return 'deep brown';
    if (value == 0xFF5C3424) return 'very deep brown';
    if (value == 0xFF3B2219) return 'dark deep brown';
    return 'natural';
  }

  static String _skinDetailPhrase(AvatarSkinDetail detail) {
    switch (detail) {
      case AvatarSkinDetail.none:
        return '';
      case AvatarSkinDetail.freckles:
        return 'natural freckles';
      case AvatarSkinDetail.vitiligo:
        return 'natural vitiligo pattern';
      case AvatarSkinDetail.birthmark:
        return 'a natural birthmark';
      case AvatarSkinDetail.scar:
        return 'a subtle healed scar';
      case AvatarSkinDetail.rosacea:
        return 'natural cheek redness';
      case AvatarSkinDetail.matureLines:
        return 'soft mature facial lines';
    }
  }

  static String _accessibilityPhrase(AvatarAccessibilityItem item) {
    switch (item) {
      case AvatarAccessibilityItem.glasses:
        return 'glasses';
      case AvatarAccessibilityItem.hearingAidLeft:
        return 'a left hearing aid';
      case AvatarAccessibilityItem.hearingAidRight:
        return 'a right hearing aid';
      case AvatarAccessibilityItem.cochlearImplant:
        return 'a cochlear implant';
      case AvatarAccessibilityItem.sensoryHeadphones:
        return 'sensory headphones';
      case AvatarAccessibilityItem.medicalPatch:
        return 'a discreet medical patch';
      case AvatarAccessibilityItem.glucoseMonitor:
        return 'a discreet glucose monitor';
      case AvatarAccessibilityItem.prostheticArmIndicator:
        return 'a respectful prosthetic arm indicator';
    }
  }

  static String _culturalPhrase(AvatarCulturalItem item) {
    switch (item) {
      case AvatarCulturalItem.none:
        return '';
      case AvatarCulturalItem.hijab:
        return 'a hijab';
      case AvatarCulturalItem.turban:
        return 'a turban';
      case AvatarCulturalItem.headwrap:
        return 'a headwrap';
      case AvatarCulturalItem.kippah:
        return 'a kippah';
    }
  }

  static String _abstractPrompt(UserAvatarProfile profile) {
    return 'A private abstract wellness avatar, soft glowing aura, '
        'calm friendly identity symbol, non-human, inclusive, clean background, '
        'modern app avatar style.';
  }
}
