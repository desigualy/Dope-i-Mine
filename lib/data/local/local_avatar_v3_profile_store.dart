import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/avatar_v3/avatar_v3_profile.dart';

final localAvatarV3ProfileStoreProvider =
    Provider<LocalAvatarV3ProfileStore>((ref) {
  return LocalAvatarV3ProfileStore();
});

class LocalAvatarV3ProfileStore {
  static const String _key = 'dope_i_mine.avatar_v3.profile';

  Future<AvatarV3Profile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;

    try {
      final json = jsonDecode(raw);
      if (json is Map<String, dynamic>) {
        return AvatarV3Profile.fromJson(json);
      }
      if (json is Map) {
        return AvatarV3Profile.fromJson(Map<String, dynamic>.from(json));
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  Future<void> saveProfile(AvatarV3Profile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
