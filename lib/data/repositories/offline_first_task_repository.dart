// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:flutter/foundation.dart';

import '../../core/network/connectivity_controller.dart';
import '../../core/network/connectivity_status.dart';
import '../../core/sync/sync_queue_item.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../domain/sidequests/side_quest_model.dart';
import '../../domain/tasks/task_model.dart';
import '../../domain/tasks/task_state_snapshot.dart';
import '../../domain/tasks/task_step_model.dart';
import '../local/local_reward_store.dart';
import '../local/local_task_store.dart';
import 'task_repository_impl.dart';

class OfflineFirstTaskRepository {
  OfflineFirstTaskRepository({
    required this.localTaskStore,
    required this.localRewardStore,
    required this.syncQueue,
    required this.connectivityController,
    this.remote,
  });

  final TaskRepositoryImpl? remote;
  final LocalTaskStore localTaskStore;
  final LocalRewardStore localRewardStore;
  final SyncQueueService syncQueue;
  final ConnectivityController connectivityController;

  Future<
      ({
        TaskModel task,
        List<TaskStepModel> steps,
        List<TaskStepModel> minimumVersion,
        List<SideQuestModel> sideQuests,
      })> createTask({
    required String userId,
    required String sourceText,
    required TaskStateSnapshot snapshot,
  }) async {
    final online = await connectivityController.refresh();
    if (remote != null && online.isOnline) {
      try {
        final result = await remote!.createTask(
          userId: userId,
          sourceText: sourceText,
          snapshot: snapshot,
        );
        await localTaskStore.saveTaskBundle(LocalTaskBundle(
          task: result.task,
          steps: result.steps,
          minimumVersion: result.minimumVersion,
          sideQuests: result.sideQuests,
        ));
        return result;
      } catch (error) {
        debugPrint('Remote createTask failed; using offline fallback: $error');
      }
    }

    final bundle = _buildLocalTaskBundle(
      userId: userId,
      sourceText: sourceText,
      snapshot: snapshot,
    );
    await localTaskStore.saveTaskBundle(bundle);
    await syncQueue.enqueue(SyncQueueItem.create(
      type: 'create_task',
      idempotencyKey: 'create_task_${bundle.task.id}',
      payload: <String, dynamic>{
        'localTaskId': bundle.task.id,
        'userId': userId,
        'sourceText': sourceText,
        'snapshot': snapshot.toJson(),
        'createdOffline': true,
      },
    ));

    return (
      task: bundle.task,
      steps: bundle.steps,
      minimumVersion: bundle.minimumVersion,
      sideQuests: bundle.sideQuests,
    );
  }

  Future<List<TaskStepModel>> breakDownStep({
    required String stepId,
    required TaskStateSnapshot snapshot,
    required String stepText,
  }) async {
    final online = await connectivityController.refresh();
    if (remote != null && online.isOnline && !stepId.startsWith('local_')) {
      try {
        final remoteSteps = await remote!.breakDownStep(
          stepId: stepId,
          snapshot: snapshot,
          stepText: stepText,
        );
        await localTaskStore.upsertSteps(remoteSteps);
        return remoteSteps;
      } catch (error) {
        debugPrint('Remote breakDownStep failed; using offline fallback: $error');
      }
    }

    final data = localBreakdownFallback(stepText);
    final substeps = (data['substeps'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map>()
        .map((item) => item['text'] as String? ?? '')
        .where((text) => text.trim().isNotEmpty)
        .toList();
    final now = DateTime.now().microsecondsSinceEpoch;
    final generated = substeps.asMap().entries.map((entry) {
      return TaskStepModel(
        id: 'local_step_${now}_${entry.key}',
        taskId: 'local_unknown_task',
        parentStepId: stepId,
        text: entry.value,
        sequenceNo: entry.key + 1,
        depthLevel: 1,
      );
    }).toList();
    await localTaskStore.upsertSteps(generated);
    await syncQueue.enqueue(SyncQueueItem.create(
      type: 'breakdown_step',
      idempotencyKey: 'breakdown_step_$stepId',
      payload: <String, dynamic>{
        'stepId': stepId,
        'stepText': stepText,
        'snapshot': snapshot.toJson(),
      },
    ));
    return generated;
  }

  Future<void> completeStep({
    required String userId,
    required String stepId,
  }) async {
    await localTaskStore.completeStep(stepId);
    await localRewardStore.awardXp(
      userId: userId,
      amount: 10,
      key: 'step_completed',
      sourceType: 'step',
      sourceId: stepId,
    );

    final online = await connectivityController.refresh();
    if (remote != null && online.isOnline && !stepId.startsWith('local_')) {
      try {
        await remote!.completeStep(userId: userId, stepId: stepId);
        return;
      } catch (error) {
        debugPrint('Remote completeStep failed; queued for sync: $error');
      }
    }

    await syncQueue.enqueue(SyncQueueItem.create(
      type: 'complete_step',
      idempotencyKey: 'complete_step_${userId}_$stepId',
      payload: <String, dynamic>{
        'userId': userId,
        'stepId': stepId,
        'completedAt': DateTime.now().toUtc().toIso8601String(),
      },
    ));
  }

  LocalTaskBundle _buildLocalTaskBundle({
    required String userId,
    required String sourceText,
    required TaskStateSnapshot snapshot,
  }) {
    final data = localTaskFallback(sourceText, snapshot);
    final now = DateTime.now().microsecondsSinceEpoch;
    final taskId = 'local_task_$now';
    final title = data['normalizedTitle'] as String? ?? sourceText.trim();
    final task = TaskModel(
      id: taskId,
      normalizedTitle: title.isEmpty ? 'New task' : title,
      effortBand: data['effortBand'] as String? ?? 'medium',
      estimatedMinutes: data['estimatedMinutes'] as int? ?? 15,
      category: data['category'] as String?,
    );

    final rawPrimary = data['primarySteps'] as List<dynamic>? ?? const <dynamic>[];
    final steps = <TaskStepModel>[];
    var sequence = 1;
    for (final item in rawPrimary.whereType<Map>()) {
      final sectionId = 'local_step_${now}_$sequence';
      steps.add(TaskStepModel(
        id: sectionId,
        taskId: taskId,
        text: item['text'] as String? ?? 'Start',
        sequenceNo: sequence,
        depthLevel: 0,
        isOptional: item['isOptional'] as bool? ?? false,
      ));
      final substeps = item['substeps'] as List<dynamic>? ?? const <dynamic>[];
      for (final subEntry in substeps.whereType<Map>().toList().asMap().entries) {
        steps.add(TaskStepModel(
          id: '${sectionId}_child_${subEntry.key}',
          taskId: taskId,
          parentStepId: sectionId,
          text: subEntry.value['text'] as String? ?? 'Next step',
          sequenceNo: subEntry.key + 1,
          depthLevel: 1,
        ));
      }
      sequence++;
    }

    final minimum = (data['minimumVersionSteps'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map>()
        .toList()
        .asMap()
        .entries
        .map<TaskStepModel>((entry) => TaskStepModel(
              id: 'local_min_${now}_${entry.key}',
              taskId: taskId,
              text: entry.value['text'] as String? ?? 'Do the smallest first step',
              sequenceNo: entry.key + 1,
              depthLevel: 0,
              isMinimumPath: true,
            ))
        .toList();

    final sideQuests = (data['sideQuests'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map>()
        .toList()
        .asMap()
        .entries
        .map<SideQuestModel>((entry) => SideQuestModel(
              id: 'local_sidequest_${now}_${entry.key}',
              title: entry.value['title'] as String? ?? 'Tiny bonus action',
              questType: (entry.value['quest_type'] ?? entry.value['questType'] ?? 'bonus') as String,
              rewardXp: (entry.value['reward_xp'] ?? entry.value['rewardXp'] ?? 10) as int,
              status: 'available',
              taskId: taskId,
            ))
        .toList();

    return LocalTaskBundle(
      task: task,
      steps: steps,
      minimumVersion: minimum,
      sideQuests: sideQuests,
    );
  }
}
