
import 'dart:ui';

import '../../domain/branding/pronunciation_option.dart';
import '../../domain/branding/reward_phrase.dart';
import '../../domain/branding/skin_pack_model.dart';
import '../../domain/voice/regional_pronunciation_model.dart';

class BrandingRepositoryImpl {
  RegionalPronunciationModel detectRegionalDefault(Locale locale) {
    final code = locale.toLanguageTag();
    if (code.startsWith('en-US')) {
      return const RegionalPronunciationModel(
        localeCode: 'en-US',
        defaultOption: PronunciationOption.dopy,
      );
    }
    if (code.startsWith('en-GB')) {
      return const RegionalPronunciationModel(
        localeCode: 'en-GB',
        defaultOption: PronunciationOption.dopeEe,
      );
    }
    if (code.startsWith('en-AU')) {
      return const RegionalPronunciationModel(
        localeCode: 'en-AU',
        defaultOption: PronunciationOption.dopeEe,
      );
    }
    return const RegionalPronunciationModel(
      localeCode: 'fallback',
      defaultOption: PronunciationOption.dopeEe,
    );
  }

  Future<List<SkinPackModel>> getSkinPackCatalogue() async {
    return const <SkinPackModel>[
      SkinPackModel(
        id: 'classic',
        skinKey: 'classic',
        title: 'Classic',
        tier: 'free',
        isActive: true,
        description: 'The default Dope-i look. Calm, familiar, and included for everyone.',
        previewAssetPath: 'assets/mascots/dope_i/skins/classic/',
      ),
      SkinPackModel(
        id: 'cozy',
        skinKey: 'cozy',
        title: 'Cozy Pack',
        tier: 'premium',
        isActive: true,
        description: 'Soft comfort styling for low-stimulation days and calmer routines.',
        previewAssetPath: 'assets/mascots/dope_i/skins/cozy/',
      ),
      SkinPackModel(
        id: 'cyber',
        skinKey: 'cyber',
        title: 'Cyber Pack',
        tier: 'premium',
        isActive: true,
        description: 'Bright futuristic styling for users who like a sharper visual edge.',
        previewAssetPath: 'assets/mascots/dope_i/skins/cyber/',
      ),
      SkinPackModel(
        id: 'fantasy',
        skinKey: 'fantasy',
        title: 'Fantasy Pack',
        tier: 'premium',
        isActive: true,
        description: 'Quest-flavoured skins for people who want the app to feel more magical.',
        previewAssetPath: 'assets/mascots/dope_i/skins/fantasy/',
      ),
      SkinPackModel(
        id: 'seasonal',
        skinKey: 'seasonal',
        title: 'Seasonal Pack',
        tier: 'seasonal',
        isActive: true,
        description: 'Limited-time skins rotated by season and event calendar.',
        previewAssetPath: 'assets/mascots/dope_i/skins/seasonal/',
      ),
      SkinPackModel(
        id: 'space',
        skinKey: 'space',
        title: 'Space Pack',
        tier: 'premium',
        isActive: true,
        description: 'Low-gravity Dope-i styling for users who like a cosmic look.',
        previewAssetPath: 'assets/mascots/dope_i/skins/space/',
      ),
    ];
  }

  List<String> getRewardPhrases(RewardPhraseType type) {
    switch (type) {
      case RewardPhraseType.microStep:
        return const <String>[
          'Nice move.',
          'One brick laid.',
          'Progress counts.',
          'That mattered.',
          'Good push.',
        ];
      case RewardPhraseType.taskComplete:
        return const <String>[
          'Strong finish.',
          'You did it.',
          'Another win banked.',
          'Momentum secured.',
          'Proof you can.',
        ];
      case RewardPhraseType.recovery:
        return const <String>[
          'You came back. That counts.',
          'Restart accepted.',
          'We go smaller.',
          'One breath, one move.',
          'Still in the game.',
        ];
    }
  }

  List<String> getVoiceNamePreviews() {
    return const <String>[
      'Dope-ee',
      'Dopy',
      'Dope-eye',
    ];
  }
}
