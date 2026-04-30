import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/companion/avatar_config_model.dart';
import '../../providers.dart';

final currentUserAvatarConfigProvider =
    FutureProvider<AvatarConfigModel>((ref) async {
  if (ref.read(supabaseProvider) == null) {
    return AvatarConfigModel.defaults;
  }

  try {
    final authUser = ref.read(authRepositoryProvider).getCurrentUser();
    if (authUser == null) return AvatarConfigModel.defaults;

    final config = await ref
        .read(companionRepositoryProvider)
        .getAvatarConfig(authUser.id);
    return config ?? AvatarConfigModel.defaults;
  } catch (_) {
    return AvatarConfigModel.defaults;
  }
});
