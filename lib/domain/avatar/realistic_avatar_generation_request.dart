import 'realistic_avatar_prompt_builder.dart';
import 'user_avatar_profile.dart';

class RealisticAvatarGenerationRequest {
  const RealisticAvatarGenerationRequest({
    required this.profile,
    required this.prompt,
    required this.negativePrompt,
    this.size = '1024x1024',
  });

  final UserAvatarProfile profile;
  final String prompt;
  final String negativePrompt;
  final String size;

  factory RealisticAvatarGenerationRequest.fromProfile(
    UserAvatarProfile profile,
  ) {
    return RealisticAvatarGenerationRequest(
      profile: profile,
      prompt: RealisticAvatarPromptBuilder.build(profile),
      negativePrompt: RealisticAvatarPromptBuilder.negativePrompt(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'prompt': prompt,
      'negativePrompt': negativePrompt,
      'size': size,
      'profile': RealisticAvatarPromptBuilder.buildPayload(profile)['profile'],
    };
  }
}
