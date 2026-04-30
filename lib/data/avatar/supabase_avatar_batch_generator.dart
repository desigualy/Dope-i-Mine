import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/avatar/avatar_generation_batch_request.dart';
import '../../domain/avatar/avatar_generation_batch_result.dart';
import 'avatar_batch_generator.dart';

class SupabaseAvatarBatchGenerator implements AvatarBatchGenerator {
  const SupabaseAvatarBatchGenerator(this.client);

  final SupabaseClient client;

  @override
  Future<AvatarGenerationBatchResult> generateBatch(
    AvatarGenerationBatchRequest request,
  ) async {
    final response = await client.functions.invoke(
      'generate-avatar-candidates',
      body: request.toJson(),
    );

    final data = response.data;

    if (data is! Map) {
      throw const AvatarBatchGenerationException(
        'Avatar candidate service returned an invalid response.',
      );
    }

    final result = AvatarGenerationBatchResult.fromJson(
      data.cast<String, dynamic>(),
    );

    if (result.candidates.isEmpty) {
      throw const AvatarBatchGenerationException(
        'Avatar candidate service returned no candidates.',
      );
    }

    return result;
  }
}
