// ignore_for_file: prefer_const_declarations
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/local_avatar_v3_inventory_store.dart';
import '../../data/local/local_avatar_v3_pending_sync_store.dart';
import '../../data/local/local_avatar_v3_profile_store.dart';
import '../../data/repositories/offline_first_avatar_v3_repository.dart';
import '../../domain/avatar_v3/avatar_v3_migration.dart';
import '../../domain/avatar_v3/avatar_v3_options.dart';
import '../../domain/avatar_v3/avatar_v3_profile.dart';

final avatarV3RepositoryProvider = Provider<OfflineFirstAvatarV3Repository>((ref) {
  return OfflineFirstAvatarV3Repository(
    profileStore: ref.watch(localAvatarV3ProfileStoreProvider),
    inventoryStore: ref.watch(localAvatarV3InventoryStoreProvider),
    pendingSyncStore: ref.watch(localAvatarV3PendingSyncStoreProvider),
  );
});

final currentAvatarV3Provider = FutureProvider<AvatarV3Profile>((ref) async {
  final repository = ref.watch(avatarV3RepositoryProvider);
  final saved = await repository.loadProfile();
  if (saved != null) return AvatarV3Options.normalize(saved);

  final initial = AvatarV3Migration.defaultReferenceProfile;
  await repository.saveProfile(initial);
  return AvatarV3Options.normalize(initial);
});

final avatarV3SaveControllerProvider = Provider<AvatarV3SaveController>((ref) {
  return AvatarV3SaveController(ref);
});

class AvatarV3SaveController {
  AvatarV3SaveController(this._ref);

  final Ref _ref;

  Future<void> save(AvatarV3Profile profile) async {
    await _ref.read(avatarV3RepositoryProvider).saveProfile(profile);
    _ref.invalidate(currentAvatarV3Provider);
  }
}
