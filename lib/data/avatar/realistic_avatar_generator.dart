import '../../domain/avatar/realistic_avatar_generation_request.dart';
import '../../domain/avatar/realistic_avatar_generation_result.dart';

abstract class RealisticAvatarGenerator {
  Future<RealisticAvatarGenerationResult> generate(
    RealisticAvatarGenerationRequest request,
  );
}

class RealisticAvatarGenerationException implements Exception {
  const RealisticAvatarGenerationException(this.message);

  final String message;

  @override
  String toString() => 'RealisticAvatarGenerationException: $message';
}
