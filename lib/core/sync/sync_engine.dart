import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/connectivity_controller.dart';
import '../network/connectivity_status.dart';
import 'sync_queue_item.dart';
import 'sync_queue_service.dart';

class SyncEngine {
  SyncEngine({
    required this.queueService,
    required this.connectivityController,
    this.supabaseClient,
  });

  final SyncQueueService queueService;
  final ConnectivityController connectivityController;
  final SupabaseClient? supabaseClient;

  Future<int> syncNow() async {
    final status = await connectivityController.refresh();
    if (!status.isOnline || supabaseClient == null) return 0;

    final queue = await queueService.loadQueue();
    var syncedCount = 0;
    for (final item in queue.where((item) => item.shouldAttempt)) {
      await queueService.markSyncing(item.id);
      try {
        await _syncItem(item);
        await queueService.markSynced(item.id);
        syncedCount++;
      } catch (error) {
        debugPrint('Sync failed for ${item.type}: $error');
        await queueService.markFailed(item.id, error);
      }
    }
    await queueService.clearSynced();
    return syncedCount;
  }

  Future<void> _syncItem(SyncQueueItem item) async {
    switch (item.type) {
      case 'complete_step':
        await _syncCompleteStep(item);
        return;
      case 'create_task':
      case 'breakdown_step':
      case 'avatar_update':
      case 'routine_update':
        // These require local-to-remote ID reconciliation. Keep queued until
        // their dedicated repository sync pass maps local IDs safely.
        throw StateError('${item.type} needs dedicated sync reconciliation.');
      default:
        throw StateError('Unknown sync item type: ${item.type}');
    }
  }

  Future<void> _syncCompleteStep(SyncQueueItem item) async {
    final payload = item.payload;
    final userId = payload['userId'] as String?;
    final stepId = payload['stepId'] as String?;
    if (userId == null || stepId == null || stepId.startsWith('local_')) {
      throw StateError('Cannot sync complete_step without remote user/step IDs.');
    }

    await supabaseClient!.from('task_steps').update(<String, dynamic>{
      'completion_status': 'completed',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', stepId);

    final row = await supabaseClient!
        .from('task_steps')
        .select('task_id')
        .eq('id', stepId)
        .single();

    await supabaseClient!.from('progress_logs').upsert(
      <String, dynamic>{
        'user_id': userId,
        'task_id': row['task_id'],
        'step_id': stepId,
        'event_type': 'step_completed',
        'metadata': <String, dynamic>{
          'idempotencyKey': item.idempotencyKey,
        },
      },
      onConflict: 'user_id,step_id,event_type',
    );
  }
}
