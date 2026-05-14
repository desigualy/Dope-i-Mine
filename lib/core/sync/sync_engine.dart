import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/local/local_task_store.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/tasks/task_state_snapshot.dart';
import '../network/connectivity_controller.dart';
import '../network/connectivity_status.dart';
import 'sync_queue_item.dart';
import 'sync_queue_service.dart';

class SyncEngine {
  SyncEngine({
    required this.queueService,
    required this.connectivityController,
    this.supabaseClient,
    this.localTaskStore,
  });

  final SyncQueueService queueService;
  final ConnectivityController connectivityController;
  final SupabaseClient? supabaseClient;
  final LocalTaskStore? localTaskStore;

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
        await _syncCreateTask(item);
        return;
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

  Future<void> _syncCreateTask(SyncQueueItem item) async {
    final payload = item.payload;
    final localTaskId = payload['localTaskId'] as String?;
    final userId = payload['userId'] as String?;
    final sourceText = payload['sourceText'] as String?;
    final snapshotJson = (payload['snapshot'] as Map?)?.cast<String, dynamic>();

    if (userId == null || sourceText == null || snapshotJson == null) {
      throw StateError('Cannot sync create_task without user/source/snapshot.');
    }

    final existingRemoteId = localTaskId == null
        ? null
        : await localTaskStore?.remoteIdFor(localTaskId);
    if (existingRemoteId != null && existingRemoteId.isNotEmpty) return;

    final result = await TaskRepositoryImpl(supabaseClient!).createTask(
      userId: userId,
      sourceText: sourceText,
      snapshot: TaskStateSnapshot.fromJson(snapshotJson),
    );

    if (localTaskId != null && localTaskStore != null) {
      await localTaskStore!.mapRemoteId(localTaskId, result.task.id);
      await localTaskStore!.saveTaskBundle(LocalTaskBundle(
        task: result.task,
        steps: result.steps,
        minimumVersion: result.minimumVersion,
        sideQuests: result.sideQuests,
      ));
    }
  }

  Future<void> _syncCompleteStep(SyncQueueItem item) async {
    final payload = item.payload;
    final userId = payload['userId'] as String?;
    final stepId = payload['stepId'] as String?;
    if (userId == null || stepId == null || stepId.startsWith('local_')) {
      throw StateError(
          'Cannot sync complete_step without remote user/step IDs.');
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
