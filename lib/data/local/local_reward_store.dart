import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_json_store.dart';

final localRewardStoreProvider = Provider<LocalRewardStore>((ref) {
  return LocalRewardStore();
});

class LocalRewardStore {
  LocalRewardStore({LocalJsonStore? store})
      : _store = store ?? LocalJsonStore('dope_i_mine.local.rewards.v1');

  final LocalJsonStore _store;
  static const String _eventsKey = 'events';
  static const String _statsKey = 'stats';

  Future<void> awardXp({
    required String userId,
    required int amount,
    required String key,
    String? sourceType,
    String? sourceId,
  }) async {
    final events = await _store.readList(_eventsKey);
    final idempotencyKey = '${userId}_${key}_${sourceType ?? 'local'}_${sourceId ?? 'none'}';
    if (events.any((row) => row['idempotencyKey'] == idempotencyKey)) return;

    await _store.writeList(_eventsKey, <Map<String, dynamic>>[
      ...events,
      <String, dynamic>{
        'id': 'reward_${DateTime.now().microsecondsSinceEpoch}',
        'userId': userId,
        'amount': amount,
        'key': key,
        'sourceType': sourceType,
        'sourceId': sourceId,
        'idempotencyKey': idempotencyKey,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      },
    ]);

    final stats = await _store.readMap(_statsKey) ?? <String, dynamic>{};
    final xp = stats['xp'] as int? ?? 0;
    await _store.writeMap(_statsKey, <String, dynamic>{...stats, 'xp': xp + amount});
  }

  Future<int> currentXp() async {
    final stats = await _store.readMap(_statsKey) ?? <String, dynamic>{};
    return stats['xp'] as int? ?? 0;
  }
}
