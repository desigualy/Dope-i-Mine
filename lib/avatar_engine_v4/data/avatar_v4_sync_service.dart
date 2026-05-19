import '../domain/avatar_v4_config.dart';
import '../domain/avatar_v4_inventory.dart';
import '../domain/avatar_v4_sync_failure.dart';
import 'avatar_v4_local_cache.dart';
import 'avatar_v4_repository.dart';

class AvatarV4SyncService {
  const AvatarV4SyncService({
    required AvatarV4LocalCache localCache,
    required AvatarV4Repository repository,
  })  : _localCache = localCache,
        _repository = repository;

  final AvatarV4LocalCache _localCache;
  final AvatarV4Repository _repository;

  Future<AvatarV4Config> loadEffectiveConfig({
    required String? userId,
    required bool isOnline,
  }) async {
    if (isOnline && userId != null && userId.trim().isNotEmpty) {
      final remote = await _repository.loadRemoteConfig(userId);
      if (remote != null) {
        await _localCache.saveConfig(remote);
        return remote;
      }
    }

    final local = await _localCache.loadConfig();
    if (local != null) return local;

    final starter = AvatarV4Config.starter();
    await _localCache.saveConfig(starter);
    return starter;
  }

  Future<void> saveConfigOnlineRequired({
    required String userId,
    required AvatarV4Config config,
    required bool isOnline,
  }) async {
    if (!isOnline) {
      throw const AvatarV4OfflineUpdateFailure();
    }

    final stamped = config.copyWith(
      updatedAtIso: DateTime.now().toUtc().toIso8601String(),
    );

    await _repository.saveRemoteConfig(userId, stamped);
    await _localCache.saveConfig(stamped);
  }

  Future<void> saveConfigLocalFirst({
    required String? userId,
    required AvatarV4Config config,
    required bool isOnline,
  }) async {
    final stamped = config.copyWith(
      updatedAtIso: DateTime.now().toUtc().toIso8601String(),
    );

    await _localCache.saveConfig(stamped);

    if (!isOnline || userId == null || userId.trim().isEmpty) {
      return;
    }

    await _repository.saveRemoteConfig(userId, stamped);
  }

  Future<AvatarV4Inventory> loadEffectiveInventory({
    required String? userId,
    required bool isOnline,
  }) async {
    if (isOnline && userId != null && userId.trim().isNotEmpty) {
      final remote = await _repository.loadRemoteInventory(userId);
      await _localCache.saveInventory(remote);
      return remote;
    }

    return _localCache.loadInventory();
  }

  Future<void> syncOwnedInventoryOnlineRequired({
    required String userId,
    required AvatarV4Inventory inventory,
    required bool isOnline,
  }) async {
    if (!isOnline) {
      throw const AvatarV4OfflineUpdateFailure();
    }

    final stamped = AvatarV4Inventory(
      ownedItemIds: inventory.ownedItemIds,
      cachedPackIds: inventory.cachedPackIds,
      lastSyncedAtIso: DateTime.now().toUtc().toIso8601String(),
    );

    await _repository.saveRemoteInventory(userId, stamped);
    await _localCache.saveInventory(stamped);
  }

  Future<void> registerUploadedReferenceImageOnlineRequired({
    required String userId,
    required String storagePath,
    required String consentVersion,
    required bool isOnline,
  }) async {
    if (!isOnline) {
      throw const AvatarV4OfflineUpdateFailure();
    }

    await _repository.registerUploadedReferenceImage(
      userId: userId,
      storagePath: storagePath,
      consentVersion: consentVersion,
    );
  }
}
