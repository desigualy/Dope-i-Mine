import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/avatar/realistic_avatar_generation_request.dart';
import '../../domain/avatar/realistic_avatar_generation_result.dart';
import 'realistic_avatar_generator.dart';

class SupabaseRealisticAvatarGenerator implements RealisticAvatarGenerator {
  const SupabaseRealisticAvatarGenerator(this.client);

  final SupabaseClient client;

  @override
  Future<RealisticAvatarGenerationResult> generate(
    RealisticAvatarGenerationRequest request,
  ) async {
    final response = await client.functions.invoke(
      'generate-realistic-avatar',
      body: request.toJson(),
    );

    final data = response.data;

    if (data is! Map) {
      throw const RealisticAvatarGenerationException(
        'Avatar service returned an invalid response.',
      );
    }

    final imageUrl = data['imageUrl'] as String?;
    if (imageUrl == null || imageUrl.isEmpty) {
      throw const RealisticAvatarGenerationException(
        'Avatar service did not return an image URL.',
      );
    }

    return RealisticAvatarGenerationResult(
      imageUrl: imageUrl,
      localPath: data['localPath'] as String?,
      providerId: data['providerId'] as String?,
      revisedPrompt: data['revisedPrompt'] as String?,
    );
  }
}
