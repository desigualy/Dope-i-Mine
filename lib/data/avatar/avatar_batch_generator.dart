import '../../domain/avatar/avatar_generation_batch_request.dart';
import '../../domain/avatar/avatar_generation_batch_result.dart';

abstract class AvatarBatchGenerator {
  Future<AvatarGenerationBatchResult> generateBatch(
    AvatarGenerationBatchRequest request,
  );
}

class AvatarBatchGenerationException implements Exception {
  const AvatarBatchGenerationException(this.message);

  final String message;

  @override
  String toString() => 'AvatarBatchGenerationException: $message';
}
