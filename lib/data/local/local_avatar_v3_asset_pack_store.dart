import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localAvatarV3AssetPackStoreProvider =
    Provider<LocalAvatarV3AssetPackStore>((ref) {
  return LocalAvatarV3AssetPackStore();
});

class InstalledAvatarV3AssetPack {
  const InstalledAvatarV3AssetPack({
    required this.packId,
    required this.version,
    required this.localPath,
    required this.checksum,
    this.installedAt,
  });

  final String packId;
  final int version;
  final String localPath;
  final String checksum;
  final DateTime? installedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'packId': packId,
        'version': version,
        'localPath': localPath,
        'checksum': checksum,
        'installedAt': installedAt?.toUtc().toIso8601String(),
      };

  factory InstalledAvatarV3AssetPack.fromJson(Map<String, dynamic> json) {
    return InstalledAvatarV3AssetPack(
      packId: json['packId'] as String? ?? 'starter_pack',
      version: json['version'] as int? ?? 1,
      localPath: json['localPath'] as String? ?? '',
      checksum: json['checksum'] as String? ?? '',
      installedAt: json['installedAt'] is String
          ? DateTime.tryParse(json['installedAt'] as String)
          : null,
    );
  }
}

class LocalAvatarV3AssetPackStore {
  static const String _key = 'dope_i_mine.avatar_v3.asset_packs';

  Future<List<InstalledAvatarV3AssetPack>> loadInstalledPacks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return const <InstalledAvatarV3AssetPack>[
        InstalledAvatarV3AssetPack(
          packId: 'starter_pack',
          version: 1,
          localPath: 'assets/avatar_v3/',
          checksum: 'bundled',
        ),
      ];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(InstalledAvatarV3AssetPack.fromJson)
            .toList();
      }
    } catch (_) {
      return const <InstalledAvatarV3AssetPack>[];
    }

    return const <InstalledAvatarV3AssetPack>[];
  }

  Future<void> saveInstalledPacks(List<InstalledAvatarV3AssetPack> packs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(packs.map((pack) => pack.toJson()).toList()),
    );
  }
}
