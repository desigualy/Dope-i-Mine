import 'package:flutter/material.dart';

enum AvatarMode {
  looksLikeMe,
  inspiredByMe,
  privateAbstract,
}

enum AvatarRenderMode {
  illustrated,
  premiumPortrait,
  ultraRealistic,
  abstract,
}

enum AvatarRealismLevel {
  soft,
  semiRealistic,
  ultraRealistic,
}

enum AvatarLightingStyle {
  studio,
  softNatural,
  neon,
  warm,
  cool,
}

enum AvatarCameraStyle {
  headshot,
  shoulders,
  bust,
}

enum AvatarAgePresentation {
  child,
  preTeen,
  teen,
  youngAdult,
  adult,
  olderAdult,
}

enum AvatarBodyPresentation {
  petite,
  slim,
  average,
  broad,
  larger,
  muscular,
  seated,
}

enum AvatarHairType {
  none,
  straight,
  wavy,
  curly,
  coily,
  afro,
  locs,
  braids,
  twists,
  shaved,
  covered,
}

enum AvatarHairLength {
  bald,
  short,
  medium,
  long,
}

enum AvatarFaceShape {
  oval,
  round,
  square,
  heart,
  long,
}

enum AvatarExpression {
  neutral,
  calm,
  happy,
  focused,
  proud,
  tired,
  overwhelmed,
}

enum AvatarSkinDetail {
  none,
  freckles,
  vitiligo,
  birthmark,
  scar,
  rosacea,
  matureLines,
}

enum AvatarAccessibilityItem {
  glasses,
  hearingAidLeft,
  hearingAidRight,
  cochlearImplant,
  sensoryHeadphones,
  medicalPatch,
  glucoseMonitor,
  prostheticArmIndicator,
}

enum AvatarCulturalItem {
  none,
  hijab,
  turban,
  headwrap,
  kippah,
}

enum DopeiMood {
  neutral,
  focused,
  happy,
  celebration,
  overwhelmed,
  calm,
  encouraging,
  proud,
}

extension AppEnumLabel on Enum {
  String get label {
    final raw = name;
    final buffer = StringBuffer();

    for (var i = 0; i < raw.length; i++) {
      final char = raw[i];
      final isUpper = char.toUpperCase() == char && char.toLowerCase() != char;
      if (i > 0 && isUpper) {
        buffer.write(' ');
      }
      buffer.write(i == 0 ? char.toUpperCase() : char);
    }

    return buffer.toString();
  }
}

extension DopeiMoodSemantics on DopeiMood {
  String get semanticLabel {
    switch (this) {
      case DopeiMood.neutral:
        return 'Dope-i is ready';
      case DopeiMood.focused:
        return 'Dope-i is focused with you';
      case DopeiMood.happy:
        return 'Dope-i is happy with your progress';
      case DopeiMood.celebration:
        return 'Dope-i is celebrating your win';
      case DopeiMood.overwhelmed:
        return 'Dope-i notices things feel heavy';
      case DopeiMood.calm:
        return 'Dope-i is calm and steady';
      case DopeiMood.encouraging:
        return 'Dope-i is encouraging you';
      case DopeiMood.proud:
        return 'Dope-i is proud of your effort';
    }
  }
}

class AvatarPalettes {
  const AvatarPalettes._();

  static const List<Color> skinTones = <Color>[
    Color(0xFFFFDBB5),
    Color(0xFFEFC29A),
    Color(0xFFDFA878),
    Color(0xFFC68642),
    Color(0xFFB87952),
    Color(0xFF8D5524),
    Color(0xFF5C3424),
    Color(0xFF3B2219),
  ];

  static const List<Color> hairColors = <Color>[
    Color(0xFF111827),
    Color(0xFF2A1710),
    Color(0xFF5C4033),
    Color(0xFF8B4513),
    Color(0xFFB45309),
    Color(0xFFEAB308),
    Color(0xFFD1D5DB),
    Color(0xFFF8FAFC),
    Color(0xFF7C3AED),
    Color(0xFF06B6D4),
    Color(0xFFEC4899),
  ];

  static const List<Color> accentColors = <Color>[
    Color(0xFF22D3EE),
    Color(0xFF8B5CF6),
    Color(0xFF34D399),
    Color(0xFFF59E0B),
    Color(0xFFFB7185),
    Color(0xFFA3E635),
  ];
}
