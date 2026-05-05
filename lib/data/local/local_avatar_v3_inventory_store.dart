import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localAvatarV3InventoryStoreProvider =
    Provider<LocalAvatarV3InventoryStore>((ref) {
  return LocalAvatarV3InventoryStore();
});

class AvatarV3Inventory {
  const AvatarV3Inventory({
    this.ownedAssetIds = const <String>[],
    this.ownedPackIds = const <String>['starter_pack'],
    this.updatedAt,
  });

  final List<String> ownedAssetIds;
  final List<String> ownedPackIds;
  final DateTime? updatedAt;

  bool ownsAsset(String assetId) => ownedAssetIds.contains(assetId);
  bool ownsPack(String packId) => ownedPackIds.contains(packId);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'ownedAssetIds': ownedAssetIds,
        'ownedPackIds': ownedPackIds,
        'updatedAt': updatedAt?.toUtc().toIso8601String(),
      };

  factory AvatarV3Inventory.fromJson(Map<String, dynamic> json) {
    return AvatarV3Inventory(
      ownedAssetIds: (json['ownedAssetIds'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>()
          .toList(),
      ownedPackIds: (json['ownedPackIds'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>()
          .toList(),
      updatedAt: json['updatedAt'] is String
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }
}

class LocalAvatarV3InventoryStore {
  static const String _key = 'dope_i_mine.avatar_v3.inventory';

  Future<AvatarV3Inventory> loadInventory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const AvatarV3Inventory();

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return AvatarV3Inventory.fromJson(decoded);
      }
      if (decoded is Map) {
        return AvatarV3Inventory.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      return const AvatarV3Inventory();
    }

    return const AvatarV3Inventory();
  }

  Future<void> saveInventory(AvatarV3Inventory inventory) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(inventory.toJson()));
  }
}
