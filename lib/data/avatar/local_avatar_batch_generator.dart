import '../../domain/avatar/avatar_generation_batch_request.dart';
import '../../domain/avatar/avatar_generation_batch_result.dart';
import 'avatar_batch_generator.dart';

class LocalAvatarBatchGenerator implements AvatarBatchGenerator {
  const LocalAvatarBatchGenerator();

  @override
  Future<AvatarGenerationBatchResult> generateBatch(
    AvatarGenerationBatchRequest request,
  ) async {
    throw const AvatarBatchGenerationException(
      'No live avatar candidate generation service is configured. '
      'Configure the generate-avatar-candidates Supabase Edge Function.',
    );
  }
}
