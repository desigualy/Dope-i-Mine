import '../../domain/avatar_v3/avatar_v3_profile.dart';
import '../local/local_avatar_v3_inventory_store.dart';

abstract class AvatarV3Repository {
  Future<AvatarV3Profile?> loadProfile();
  Future<void> saveProfile(AvatarV3Profile profile);

  Future<AvatarV3Inventory> loadInventory();
  Future<void> saveInventory(AvatarV3Inventory inventory);
}
