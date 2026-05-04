import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sync_queue_item.dart';

final syncQueueServiceProvider = Provider<SyncQueueService>((ref) {
  return SyncQueueService();
});

class SyncQueueService {
  SyncQueueService({SharedPreferences? preferences}) : _preferences = preferences;

  static const String _queueKey = 'offline.sync.queue.v1';
  static const String _lastSyncKey = 'offline.sync.last_success_at.v1';

  final SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async {
    final injected = _preferences;
    if (injected != null) return injected;
    return SharedPreferences.getInstance();
  }

  Future<List<SyncQueueItem>> loadQueue() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_queueKey);
    if (raw == null || raw.trim().isEmpty) return <SyncQueueItem>[];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map>()
          .map((item) => SyncQueueItem.fromJson(item.cast<String, dynamic>()))
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } catch (_) {
      return <SyncQueueItem>[];
    }
  }

  Future<void> enqueue(SyncQueueItem item) async {
    final existing = await loadQueue();
    final alreadyQueued = existing.any((queued) =>
        queued.idempotencyKey == item.idempotencyKey &&
        queued.type == item.type &&
        queued.status != SyncQueueStatus.failed);
    if (alreadyQueued) return;
    await _save(<SyncQueueItem>[...existing, item]);
  }

  Future<void> markSyncing(String id) async {
    await _update(id, (item) {
      return item.copyWith(
        status: SyncQueueStatus.syncing,
        attempts: item.attempts + 1,
        updatedAt: DateTime.now().toUtc(),
        clearLastError: true,
      );
    });
  }

  Future<void> markSynced(String id) async {
    await _update(id, (item) {
      return item.copyWith(
        status: SyncQueueStatus.synced,
        updatedAt: DateTime.now().toUtc(),
        clearLastError: true,
      );
    });
    final prefs = await _prefs;
    await prefs.setString(_lastSyncKey, DateTime.now().toUtc().toIso8601String());
  }

  Future<void> markFailed(String id, Object error) async {
    await _update(id, (item) {
      return item.copyWith(
        status: SyncQueueStatus.failed,
        lastError: error.toString(),
        updatedAt: DateTime.now().toUtc(),
      );
    });
  }

  Future<void> clearSynced() async {
    final queue = await loadQueue();
    await _save(queue.where((item) => item.status != SyncQueueStatus.synced).toList());
  }

  Future<int> pendingCount() async {
    final queue = await loadQueue();
    return queue.where((item) => item.status != SyncQueueStatus.synced).length;
  }

  Future<DateTime?> lastSyncAt() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_lastSyncKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> _update(
    String id,
    SyncQueueItem Function(SyncQueueItem item) update,
  ) async {
    final queue = await loadQueue();
    await _save(queue.map((item) => item.id == id ? update(item) : item).toList());
  }

  Future<void> _save(List<SyncQueueItem> queue) async {
    final prefs = await _prefs;
    final json = jsonEncode(queue.map((item) => item.toJson()).toList());
    await prefs.setString(_queueKey, json);
  }
}
