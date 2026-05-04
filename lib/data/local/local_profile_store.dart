import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_json_store.dart';

final localProfileStoreProvider = Provider<LocalProfileStore>((ref) {
  return LocalProfileStore();
});

class LocalProfileStore {
  LocalProfileStore({LocalJsonStore? store})
      : _store = store ?? LocalJsonStore('dope_i_mine.local.profile.v1');

  final LocalJsonStore _store;
  static const String _profileKey = 'profile';

  Future<void> saveLocalProfile(Map<String, dynamic> profile) async {
    await _store.writeMap(_profileKey, <String, dynamic>{
      ...profile,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> loadLocalProfile() {
    return _store.readMap(_profileKey);
  }

  Future<String> localUserId() async {
    final profile = await loadLocalProfile();
    final existing = profile?['id'] as String?;
    if (existing != null && existing.isNotEmpty) return existing;
    final id = 'local_user_${DateTime.now().microsecondsSinceEpoch}';
    await saveLocalProfile(<String, dynamic>{'id': id, 'guestMode': true});
    return id;
  }
}
