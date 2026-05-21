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
      case 'complete_routine_step':
        await _syncCompleteRoutineStep(item);
        return;
      case 'save_notification_preferences':
        await _syncSaveNotificationPreferences(item);
        return;
      case 'update_sensory_settings':
        await _syncSensorySettings(item);
        return;
      case 'save_voice_settings':
        await _syncVoiceSettings(item);
        return;
      case 'create_notification':
        await _syncCreateNotification(item);
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

  Future<void> _syncCompleteRoutineStep(SyncQueueItem item) async {
    final payload = item.payload;
    final userId = payload['userId'] as String?;
    final routineId = payload['routineId'] as String?;
    final stepId = payload['stepId'] as String?;

    if (userId == null || routineId == null || stepId == null) {
      throw StateError('Cannot sync complete_routine_step without user/routine/step IDs.');
    }

    await supabaseClient!.from('progress_logs').upsert(
      <String, dynamic>{
        'user_id': userId,
        'task_id': null,
        'step_id': stepId,
        'event_type': 'routine_step_completed',
        'metadata': <String, dynamic>{
          'routine_id': routineId,
          'idempotency_key': item.idempotencyKey,
        },
      },
      onConflict: 'user_id,step_id,event_type',
    );

    try {
      await supabaseClient!.from('rewards').insert(<String, dynamic>{
        'user_id': userId,
        'reward_type': 'xp',
        'reward_key': 'routine_step_completed',
        'amount': 5,
        'source_type': 'routine_step',
        'source_id': stepId,
      });
    } catch (_) {
      // Reward writes are helpful, not critical.
    }
  }

  Future<void> _syncSaveNotificationPreferences(SyncQueueItem item) async {
    final payload = item.payload;
    final userId = payload['userId'] as String?;

    if (userId == null) {
      throw StateError('Cannot sync save_notification_preferences without a user ID.');
    }

    await supabaseClient!.from('notification_preferences').upsert(<String, dynamic>{
      'user_id': userId,
      'enabled': payload['enabled'] ?? false,
      'quiet_hours_start': payload['quietHoursStart'],
      'quiet_hours_end': payload['quietHoursEnd'],
      'allow_task_reminders': payload['allowTaskReminders'] ?? false,
      'allow_caregiver_notifications': payload['allowCaregiverNotifications'] ?? false,
      'allow_body_double_notifications': payload['allowBodyDoubleNotifications'] ?? false,
      'allow_side_quests': payload['allowSideQuests'] ?? false,
      'allow_moderation_updates': payload['allowModerationUpdates'] ?? false,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }

  Future<void> _syncSensorySettings(SyncQueueItem item) async {
    final payload = item.payload;
    final userId = payload['userId'] as String?;
    if (userId == null) {
      throw StateError('Cannot sync update_sensory_settings without a user ID.');
    }
    final updates = <String, dynamic>{
      'user_id': userId,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (payload.containsKey('reducedAnimation')) {
      updates['reduced_animation'] = payload['reducedAnimation'];
    }
    if (payload.containsKey('largeText')) {
      updates['large_text'] = payload['largeText'];
    }
    if (payload.containsKey('soundEnabled')) {
      updates['sound_enabled'] = payload['soundEnabled'];
    }
    if (payload.containsKey('softColors')) {
      updates['soft_colors'] = payload['softColors'];
    }
    if (payload.containsKey('praiseLevel')) {
      updates['praise_level'] = payload['praiseLevel'];
    }
    if (payload.containsKey('iconMode')) {
      updates['icon_mode'] = payload['iconMode'];
    }
    if (payload.containsKey('reduceSurprises')) {
      updates['reduce_surprises'] = payload['reduceSurprises'];
    }

    await supabaseClient!.from('sensory_settings').upsert(updates, onConflict: 'user_id');
  }

  Future<void> _syncVoiceSettings(SyncQueueItem item) async {
    final payload = item.payload;
    final userId = payload['userId'] as String?;
    if (userId == null) {
      throw StateError('Cannot sync save_voice_settings without a user ID.');
    }
    await supabaseClient!.from('user_voice_settings').upsert(<String, dynamic>{
      'user_id': userId,
      'active_voice_profile_id': payload['activeVoiceProfileId'],
      'locale_id': payload['localeId'],
      'speech_rate': payload['speechRate'] ?? 1.0,
      'auto_read_steps': payload['autoReadSteps'] ?? false,
      'auto_read_sidequests': payload['autoReadSidequests'] ?? false,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }

  Future<void> _syncCreateNotification(SyncQueueItem item) async {
    final payload = item.payload;
    final userId = payload['userId'] as String?;
    if (userId == null) {
      throw StateError('Cannot sync create_notification without a user ID.');
    }
    await supabaseClient!.from('app_notifications').insert(<String, dynamic>{
      'user_id': userId,
      'type': payload['type'] ?? 'general',
      'title': payload['title'],
      'body': payload['body'],
      'route': payload['route'],
      'route_params': payload['routeParams'] ?? <String, dynamic>{},
      'status': 'unread',
      'priority': payload['priority'] ?? 'normal',
      'source_type': payload['sourceType'],
      'source_id': payload['sourceId'],
      'scheduled_for': payload['scheduledFor'],
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
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
