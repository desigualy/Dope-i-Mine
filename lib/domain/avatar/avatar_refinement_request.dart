import 'user_avatar_profile.dart';

enum AvatarRefinementIntent {
  tryAgain,
  softer,
  moreRealistic,
  lessRealistic,
  warmerLighting,
  coolerLighting,
  calmerExpression,
  happierExpression,
  fixHair,
  fixSkinTone,
  fixAccessibilityItem,
  fixCulturalItem,
  useAbstractInstead,
}

class AvatarRefinementRequest {
  const AvatarRefinementRequest({
    required this.profile,
    required this.intent,
    this.userNote,
    this.previousImageUrl,
  });

  final UserAvatarProfile profile;
  final AvatarRefinementIntent intent;
  final String? userNote;
  final String? previousImageUrl;

  String get instruction {
    switch (intent) {
      case AvatarRefinementIntent.tryAgain:
        return 'Generate a new variation while preserving the same identity choices.';
      case AvatarRefinementIntent.softer:
        return 'Make the portrait softer, warmer, and less intense.';
      case AvatarRefinementIntent.moreRealistic:
        return 'Make the portrait more realistic while avoiding uncanny valley.';
      case AvatarRefinementIntent.lessRealistic:
        return 'Make the portrait less realistic and more softly illustrated.';
      case AvatarRefinementIntent.warmerLighting:
        return 'Use warmer, more comforting lighting.';
      case AvatarRefinementIntent.coolerLighting:
        return 'Use cooler, calmer lighting.';
      case AvatarRefinementIntent.calmerExpression:
        return 'Make the expression calmer and more reassuring.';
      case AvatarRefinementIntent.happierExpression:
        return 'Make the expression happier but still natural.';
      case AvatarRefinementIntent.fixHair:
        return 'Correct the hair type, length, texture, or coverage to match the selected profile.';
      case AvatarRefinementIntent.fixSkinTone:
        return 'Correct the skin tone to match the selected profile respectfully.';
      case AvatarRefinementIntent.fixAccessibilityItem:
        return 'Correct the accessibility item so it is visible and respectful.';
      case AvatarRefinementIntent.fixCulturalItem:
        return 'Correct the cultural or head covering item respectfully.';
      case AvatarRefinementIntent.useAbstractInstead:
        return 'Switch to a private abstract non-human avatar.';
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'intent': intent.name,
      'instruction': instruction,
      'userNote': userNote,
      'previousImageUrl': previousImageUrl,
    };
  }
}
