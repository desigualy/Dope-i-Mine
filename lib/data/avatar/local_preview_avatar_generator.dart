import '../../domain/avatar/realistic_avatar_generation_request.dart';
import '../../domain/avatar/realistic_avatar_generation_result.dart';
import 'realistic_avatar_generator.dart';

class LocalPreviewAvatarGenerator implements RealisticAvatarGenerator {
  const LocalPreviewAvatarGenerator();

  @override
  Future<RealisticAvatarGenerationResult> generate(
    RealisticAvatarGenerationRequest request,
  ) async {
    throw const RealisticAvatarGenerationException(
      'No live avatar generation service is configured. '
      'Use PremiumPortraitAvatar as fallback, or configure the '
      'generate-realistic-avatar Supabase Edge Function.',
    );
  }
}
