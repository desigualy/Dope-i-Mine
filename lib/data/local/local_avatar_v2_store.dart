import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/avatar_v2/avatar_v2_profile.dart';
import 'local_json_store.dart';

final localAvatarV2StoreProvider = Provider<LocalAvatarV2Store>((ref) {
  return LocalAvatarV2Store();
});

class LocalAvatarV2Store {
  LocalAvatarV2Store({LocalJsonStore? store})
      : _store = store ?? LocalJsonStore('dope_i_mine.local.avatar.v2');

  final LocalJsonStore _store;

  static const String _profileKey = 'profile';
  static const String _migrationKey = 'migration';

  Future<AvatarV2Profile?> loadProfile() async {
    final json = await _store.readMap(_profileKey);
    if (json == null) return null;

    try {
      return AvatarV2Profile.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProfile(AvatarV2Profile profile) async {
    await _store.writeMap(
      _profileKey,
      profile
          .copyWith(updatedAt: DateTime.now().toUtc())
          .toJson(),
    );
  }

  Future<void> clearProfile() async {
    await _store.remove(_profileKey);
  }

  Future<bool> hasMigratedLegacyProfile() async {
    final json = await _store.readMap(_migrationKey);
    return json?['legacy_profile_migrated'] == true;
  }

  Future<void> markLegacyProfileMigrated() async {
    await _store.writeMap(_migrationKey, <String, dynamic>{
      'legacy_profile_migrated': true,
      'at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
