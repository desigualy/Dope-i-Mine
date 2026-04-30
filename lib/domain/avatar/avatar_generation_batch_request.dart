import 'avatar_generation_policy.dart';
import 'avatar_seed.dart';
import 'avatar_style_preset.dart';
import 'avatar_variation_strength.dart';
import 'realistic_avatar_prompt_builder.dart';
import 'structured_realistic_avatar_prompt_builder.dart';
import 'user_avatar_profile.dart';

class AvatarGenerationBatchRequest {
  const AvatarGenerationBatchRequest({
    required this.profile,
    required this.prompt,
    required this.negativePrompt,
    required this.policy,
    required this.seed,
    required this.stylePreset,
    required this.variationStrength,
    this.count = 4,
    this.size = '1024x1024',
  });

  final UserAvatarProfile profile;
  final String prompt;
  final String negativePrompt;
  final AvatarGenerationPolicy policy;
  final AvatarSeed seed;
  final AvatarStylePreset stylePreset;
  final AvatarVariationStrength variationStrength;
  final int count;
  final String size;

  factory AvatarGenerationBatchRequest.fromProfile({
    required UserAvatarProfile profile,
    required AvatarStylePreset stylePreset,
    required AvatarVariationStrength variationStrength,
    AvatarSeed? seed,
    int count = 4,
  }) {
    final preparedProfile = profile.copyWith(
      renderMode: stylePreset.renderMode,
      realismLevel: stylePreset.realismLevel,
      lightingStyle: stylePreset.lightingStyle,
    );

    final prompt = StructuredRealisticAvatarPromptBuilder.buildStructured(
      preparedProfile,
      stylePreset: stylePreset,
      variationStrength: variationStrength,
    );

    return AvatarGenerationBatchRequest(
      profile: preparedProfile,
      prompt: prompt,
      negativePrompt: StructuredRealisticAvatarPromptBuilder.negativePrompt(),
      policy: AvatarGenerationPolicy.forProfile(preparedProfile),
      seed: seed ?? AvatarSeed.create(),
      stylePreset: stylePreset,
      variationStrength: variationStrength,
      count: count.clamp(1, 6).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'prompt': prompt,
      'negativePrompt': negativePrompt,
      'count': count,
      'size': size,
      'seed': seed.toJson(),
      'stylePreset': stylePreset.name,
      'variationStrength': variationStrength.value,
      'variationStrengthName': variationStrength.name,
      'policy': policy.toJson(),
      'profile': RealisticAvatarPromptBuilder.buildPayload(profile)['profile'],
    };
  }
}
