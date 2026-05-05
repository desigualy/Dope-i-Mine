import '../../domain/avatar_v3/avatar_v3_enums.dart';
import '../../domain/avatar_v3/avatar_v3_options.dart';
import '../../domain/avatar_v3/avatar_v3_profile.dart';
import '../local/local_avatar_v3_inventory_store.dart';
import '../local/local_avatar_v3_pending_sync_store.dart';
import '../local/local_avatar_v3_profile_store.dart';
import 'avatar_v3_repository.dart';

class OfflineFirstAvatarV3Repository implements AvatarV3Repository {
  OfflineFirstAvatarV3Repository({
    required LocalAvatarV3ProfileStore profileStore,
    required LocalAvatarV3InventoryStore inventoryStore,
    required LocalAvatarV3PendingSyncStore pendingSyncStore,
  })  : _profileStore = profileStore,
        _inventoryStore = inventoryStore,
        _pendingSyncStore = pendingSyncStore;

  final LocalAvatarV3ProfileStore _profileStore;
  final LocalAvatarV3InventoryStore _inventoryStore;
  final LocalAvatarV3PendingSyncStore _pendingSyncStore;

  @override
  Future<AvatarV3Profile?> loadProfile() => _profileStore.loadProfile();

  @override
  Future<void> saveProfile(AvatarV3Profile profile) async {
    final normalized = AvatarV3Options.normalize(profile).copyWith(
      updatedAt: DateTime.now().toUtc(),
      syncStatus: AvatarV3SyncStatus.pending,
    );
    await _profileStore.saveProfile(normalized);
    await _pendingSyncStore.enqueue(
      AvatarV3PendingSyncItem(
        type: 'avatar_profile_update',
        payload: normalized.toJson(),
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }

  @override
  Future<AvatarV3Inventory> loadInventory() => _inventoryStore.loadInventory();

  @override
  Future<void> saveInventory(AvatarV3Inventory inventory) {
    return _inventoryStore.saveInventory(inventory);
  }
}
