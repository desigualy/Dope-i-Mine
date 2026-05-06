import '../domain/avatar_v4_config.dart';
import '../domain/avatar_v4_inventory.dart';

abstract class AvatarV4Repository {
  Future<AvatarV4Config?> loadRemoteConfig(String userId);
  Future<void> saveRemoteConfig(String userId, AvatarV4Config config);

  Future<AvatarV4Inventory> loadRemoteInventory(String userId);
  Future<void> saveRemoteInventory(String userId, AvatarV4Inventory inventory);

  Future<void> registerUploadedReferenceImage({
    required String userId,
    required String storagePath,
    required String consentVersion,
  });
}

class AvatarV4RepositoryUnavailable implements AvatarV4Repository {
  const AvatarV4RepositoryUnavailable();

  @override
  Future<AvatarV4Config?> loadRemoteConfig(String userId) async => null;

  @override
  Future<void> saveRemoteConfig(String userId, AvatarV4Config config) async {}

  @override
  Future<AvatarV4Inventory> loadRemoteInventory(String userId) async {
    return const AvatarV4Inventory();
  }

  @override
  Future<void> saveRemoteInventory(String userId, AvatarV4Inventory inventory) async {}

  @override
  Future<void> registerUploadedReferenceImage({
    required String userId,
    required String storagePath,
    required String consentVersion,
  }) async {}
}
