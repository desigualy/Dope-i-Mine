import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dope_i_mine/avatar_engine_v4/avatar_engine_v4.dart';

void main() {
  test('loadEffectiveConfig prefers remote config when online', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final localCache = AvatarV4LocalCache(prefs);
    final repository = _FakeAvatarV4Repository()
      ..remoteConfig = const AvatarV4Config(hairStyleId: 'remote_style');

    final service = AvatarV4SyncService(
      localCache: localCache,
      repository: repository,
    );

    final config = await service.loadEffectiveConfig(
      userId: 'user-1',
      isOnline: true,
    );

    expect(config.hairStyleId, 'remote_style');
    expect((await localCache.loadConfig())?.hairStyleId, 'remote_style');
  });

  test('saveConfigOnlineRequired rejects offline avatar edits', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final repository = _FakeAvatarV4Repository();
    final service = AvatarV4SyncService(
      localCache: AvatarV4LocalCache(prefs),
      repository: repository,
    );

    expect(
      () => service.saveConfigOnlineRequired(
        userId: 'user-1',
        config: const AvatarV4Config(hairStyleId: 'new_style'),
        isOnline: false,
      ),
      throwsA(isA<AvatarV4OfflineUpdateFailure>()),
    );

    expect(repository.savedConfig, isNull);
  });

  test('saveConfigLocalFirst persists offline edits for restart recovery',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final localCache = AvatarV4LocalCache(prefs);
    final repository = _FakeAvatarV4Repository();
    final service = AvatarV4SyncService(
      localCache: localCache,
      repository: repository,
    );

    await service.saveConfigLocalFirst(
      userId: 'user-1',
      config: const AvatarV4Config(hairStyleId: 'offline_saved_style'),
      isOnline: false,
    );

    expect(repository.savedConfig, isNull);
    expect((await localCache.loadConfig())?.hairStyleId, 'offline_saved_style');

    final afterRestart = AvatarV4SyncService(
      localCache: AvatarV4LocalCache(await SharedPreferences.getInstance()),
      repository: _FakeAvatarV4Repository(),
    );

    final restored = await afterRestart.loadEffectiveConfig(
      userId: 'user-1',
      isOnline: false,
    );

    expect(restored.hairStyleId, 'offline_saved_style');
  });

  test('saveConfigLocalFirst syncs online edits after local persistence',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final localCache = AvatarV4LocalCache(prefs);
    final repository = _FakeAvatarV4Repository();
    final service = AvatarV4SyncService(
      localCache: localCache,
      repository: repository,
    );

    await service.saveConfigLocalFirst(
      userId: 'user-1',
      config: const AvatarV4Config(hairColor: 'phase3_blue'),
      isOnline: true,
    );

    expect(repository.savedConfig?.hairColor, 'phase3_blue');
    expect((await localCache.loadConfig())?.hairColor, 'phase3_blue');
  });

  test('syncOwnedInventoryOnlineRequired saves remote and local inventory',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final localCache = AvatarV4LocalCache(prefs);
    final repository = _FakeAvatarV4Repository();
    final service = AvatarV4SyncService(
      localCache: localCache,
      repository: repository,
    );

    const inventory = AvatarV4Inventory(
      ownedItemIds: <String>['starter_black_top', 'round_clear_glasses'],
      cachedPackIds: <String>['starter_pack'],
    );

    await service.syncOwnedInventoryOnlineRequired(
      userId: 'user-1',
      inventory: inventory,
      isOnline: true,
    );

    expect(repository.savedInventory?.ownedItemIds, inventory.ownedItemIds);
    expect((await localCache.loadInventory()).ownedItemIds,
        inventory.ownedItemIds);
  });

  test('registerUploadedReferenceImageOnlineRequired requires online state',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final repository = _FakeAvatarV4Repository();
    final service = AvatarV4SyncService(
      localCache: AvatarV4LocalCache(prefs),
      repository: repository,
    );

    expect(
      () => service.registerUploadedReferenceImageOnlineRequired(
        userId: 'user-1',
        storagePath: 'avatar_uploads/user-1/ref.png',
        consentVersion: 'v1',
        isOnline: false,
      ),
      throwsA(isA<AvatarV4OfflineUpdateFailure>()),
    );
  });
}

class _FakeAvatarV4Repository implements AvatarV4Repository {
  AvatarV4Config? remoteConfig;
  AvatarV4Config? savedConfig;
  AvatarV4Inventory remoteInventory = const AvatarV4Inventory();
  AvatarV4Inventory? savedInventory;
  int uploadRegistrations = 0;

  @override
  Future<AvatarV4Config?> loadRemoteConfig(String userId) async => remoteConfig;

  @override
  Future<void> saveRemoteConfig(String userId, AvatarV4Config config) async {
    savedConfig = config;
  }

  @override
  Future<AvatarV4Inventory> loadRemoteInventory(String userId) async {
    return remoteInventory;
  }

  @override
  Future<void> saveRemoteInventory(
    String userId,
    AvatarV4Inventory inventory,
  ) async {
    savedInventory = inventory;
  }

  @override
  Future<void> registerUploadedReferenceImage({
    required String userId,
    required String storagePath,
    required String consentVersion,
  }) async {
    uploadRegistrations += 1;
  }
}
