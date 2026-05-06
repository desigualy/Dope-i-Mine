import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/avatar_v4_config.dart';
import '../domain/avatar_v4_inventory.dart';

class AvatarV4LocalCache {
  const AvatarV4LocalCache(this._prefs);

  static const String configKey = 'avatar_v4.last_selected_config';
  static const String inventoryKey = 'avatar_v4.inventory';

  final SharedPreferences _prefs;

  Future<AvatarV4Config?> loadConfig() async {
    final raw = _prefs.getString(configKey);
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return AvatarV4Config.fromJson(decoded);
      }
      if (decoded is Map) {
        return AvatarV4Config.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  Future<void> saveConfig(AvatarV4Config config) async {
    await _prefs.setString(configKey, jsonEncode(config.toJson()));
  }

  Future<AvatarV4Inventory> loadInventory() async {
    final raw = _prefs.getString(inventoryKey);
    if (raw == null || raw.trim().isEmpty) return const AvatarV4Inventory();

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return AvatarV4Inventory.fromJson(decoded);
      }
      if (decoded is Map) {
        return AvatarV4Inventory.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      return const AvatarV4Inventory();
    }

    return const AvatarV4Inventory();
  }

  Future<void> saveInventory(AvatarV4Inventory inventory) async {
    await _prefs.setString(inventoryKey, jsonEncode(inventory.toJson()));
  }
}
