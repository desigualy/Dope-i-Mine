import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localAvatarV3PendingSyncStoreProvider =
    Provider<LocalAvatarV3PendingSyncStore>((ref) {
  return LocalAvatarV3PendingSyncStore();
});

class AvatarV3PendingSyncItem {
  const AvatarV3PendingSyncItem({
    required this.type,
    required this.payload,
    required this.createdAt,
  });

  final String type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type,
        'payload': payload,
        'createdAt': createdAt.toUtc().toIso8601String(),
      };

  factory AvatarV3PendingSyncItem.fromJson(Map<String, dynamic> json) {
    return AvatarV3PendingSyncItem(
      type: json['type'] as String? ?? 'avatar_profile_update',
      payload: json['payload'] is Map<String, dynamic>
          ? json['payload'] as Map<String, dynamic>
          : <String, dynamic>{},
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now().toUtc()
          : DateTime.now().toUtc(),
    );
  }
}

class LocalAvatarV3PendingSyncStore {
  static const String _key = 'dope_i_mine.avatar_v3.pending_sync';

  Future<List<AvatarV3PendingSyncItem>> loadQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const <AvatarV3PendingSyncItem>[];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(AvatarV3PendingSyncItem.fromJson)
            .toList();
      }
    } catch (_) {
      return const <AvatarV3PendingSyncItem>[];
    }

    return const <AvatarV3PendingSyncItem>[];
  }

  Future<void> enqueue(AvatarV3PendingSyncItem item) async {
    final queue = await loadQueue();
    await saveQueue(<AvatarV3PendingSyncItem>[...queue, item]);
  }

  Future<void> saveQueue(List<AvatarV3PendingSyncItem> queue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(queue.map((e) => e.toJson()).toList()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
