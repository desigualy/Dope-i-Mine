import 'package:flutter/material.dart';

import '../../domain/avatar/avatar_enums.dart';

class AvatarMoodMapper {
  const AvatarMoodMapper._();

  static Color glowForDopeiMood(DopeiMood mood) {
    switch (mood) {
      case DopeiMood.focused:
        return Colors.deepPurpleAccent;
      case DopeiMood.happy:
        return Colors.orangeAccent;
      case DopeiMood.celebration:
        return Colors.pinkAccent;
      case DopeiMood.overwhelmed:
        return Colors.redAccent;
      case DopeiMood.calm:
        return Colors.lightBlueAccent;
      case DopeiMood.encouraging:
        return Colors.greenAccent;
      case DopeiMood.proud:
        return Colors.indigoAccent;
      case DopeiMood.neutral:
        return Colors.cyanAccent;
    }
  }

  static AvatarExpression expressionForDopeiMood(DopeiMood mood) {
    switch (mood) {
      case DopeiMood.focused:
        return AvatarExpression.focused;
      case DopeiMood.happy:
      case DopeiMood.celebration:
      case DopeiMood.encouraging:
        return AvatarExpression.happy;
      case DopeiMood.overwhelmed:
        return AvatarExpression.overwhelmed;
      case DopeiMood.calm:
        return AvatarExpression.calm;
      case DopeiMood.proud:
        return AvatarExpression.proud;
      case DopeiMood.neutral:
        return AvatarExpression.neutral;
    }
  }
}
