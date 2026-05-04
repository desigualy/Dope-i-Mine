import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/local_avatar_store.dart';
import '../../domain/companion/avatar_config_model.dart';
import '../../providers.dart';

final currentUserAvatarConfigProvider =
    FutureProvider<AvatarConfigModel>((ref) async {
  final localStore = ref.read(localAvatarStoreProvider);
  final cached = await localStore.loadAvatarConfig();

  if (ref.read(supabaseProvider) == null) {
    return cached ?? AvatarConfigModel.defaults;
  }

  try {
    final authUser = ref.read(authRepositoryProvider).getCurrentUser();
    if (authUser == null) return cached ?? AvatarConfigModel.defaults;

    final config = await ref
        .read(companionRepositoryProvider)
        .getAvatarConfig(authUser.id);
    final resolved = config ?? cached ?? AvatarConfigModel.defaults;
    if (config != null) {
      await localStore.saveAvatarConfig(config);
    }
    return resolved;
  } catch (_) {
    return cached ?? AvatarConfigModel.defaults;
  }
});
