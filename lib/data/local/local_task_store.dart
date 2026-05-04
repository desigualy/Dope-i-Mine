import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/sidequests/side_quest_model.dart';
import '../../domain/tasks/task_model.dart';
import '../../domain/tasks/task_step_model.dart';
import 'local_json_store.dart';

final localTaskStoreProvider = Provider<LocalTaskStore>((ref) {
  return LocalTaskStore();
});

class LocalTaskBundle {
  const LocalTaskBundle({
    required this.task,
    required this.steps,
    required this.minimumVersion,
    required this.sideQuests,
  });

  final TaskModel task;
  final List<TaskStepModel> steps;
  final List<TaskStepModel> minimumVersion;
  final List<SideQuestModel> sideQuests;
}

class LocalTaskStore {
  LocalTaskStore({LocalJsonStore? store})
      : _store = store ?? LocalJsonStore('dope_i_mine.local.tasks.v1');

  final LocalJsonStore _store;

  static const String _tasksKey = 'tasks';
  static const String _stepsKey = 'steps';
  static const String _sideQuestsKey = 'side_quests';
  static const String _remoteIdMapKey = 'remote_id_map';

  Future<void> saveTaskBundle(LocalTaskBundle bundle) async {
    final tasks = await _store.readList(_tasksKey);
    final steps = await _store.readList(_stepsKey);
    final sideQuests = await _store.readList(_sideQuestsKey);

    await _store.writeList(_tasksKey, <Map<String, dynamic>>[
      ...tasks.where((row) => row['id'] != bundle.task.id),
      _taskToJson(bundle.task),
    ]);

    await _store.writeList(_stepsKey, <Map<String, dynamic>>[
      ...steps.where((row) => row['taskId'] != bundle.task.id),
      ...bundle.steps.map(_stepToJson),
      ...bundle.minimumVersion.map(_stepToJson),
    ]);

    await _store.writeList(_sideQuestsKey, <Map<String, dynamic>>[
      ...sideQuests.where((row) => row['taskId'] != bundle.task.id),
      ...bundle.sideQuests.map(_sideQuestToJson),
    ]);
  }

  Future<LocalTaskBundle?> getTaskBundle(String taskId) async {
    final taskRows = await _store.readList(_tasksKey);
    final taskRow = taskRows.where((row) => row['id'] == taskId).firstOrNull;
    if (taskRow == null) return null;
    final stepRows = await _store.readList(_stepsKey);
    final sideQuestRows = await _store.readList(_sideQuestsKey);
    final allSteps = stepRows
        .where((row) => row['taskId'] == taskId)
        .map(_stepFromJson)
        .toList()
      ..sort((a, b) => a.sequenceNo.compareTo(b.sequenceNo));

    return LocalTaskBundle(
      task: _taskFromJson(taskRow),
      steps: allSteps.where((step) => !step.isMinimumPath).toList(),
      minimumVersion: allSteps.where((step) => step.isMinimumPath).toList(),
      sideQuests: sideQuestRows
          .where((row) => row['taskId'] == taskId)
          .map(_sideQuestFromJson)
          .toList(),
    );
  }

  Future<List<TaskModel>> loadTasks() async {
    final rows = await _store.readList(_tasksKey);
    return rows.map(_taskFromJson).toList();
  }

  Future<List<TaskStepModel>> loadSteps(String taskId) async {
    final rows = await _store.readList(_stepsKey);
    return rows
        .where((row) => row['taskId'] == taskId)
        .map(_stepFromJson)
        .toList()
      ..sort((a, b) => a.sequenceNo.compareTo(b.sequenceNo));
  }

  Future<void> upsertSteps(List<TaskStepModel> newSteps) async {
    if (newSteps.isEmpty) return;
    final rows = await _store.readList(_stepsKey);
    final ids = newSteps.map((step) => step.id).toSet();
    await _store.writeList(_stepsKey, <Map<String, dynamic>>[
      ...rows.where((row) => !ids.contains(row['id'])),
      ...newSteps.map(_stepToJson),
    ]);
  }

  Future<void> completeStep(String stepId) async {
    final rows = await _store.readList(_stepsKey);
    await _store.writeList(
      _stepsKey,
      rows.map((row) {
        if (row['id'] == stepId) {
          return <String, dynamic>{...row, 'status': StepStatus.completed.name};
        }
        return row;
      }).toList(),
    );
  }

  Future<void> mapRemoteId(String localId, String remoteId) async {
    final map = await _store.readMap(_remoteIdMapKey) ?? <String, dynamic>{};
    map[localId] = remoteId;
    await _store.writeMap(_remoteIdMapKey, map);
  }

  Future<String?> remoteIdFor(String localId) async {
    final map = await _store.readMap(_remoteIdMapKey) ?? <String, dynamic>{};
    return map[localId] as String?;
  }

  Map<String, dynamic> _taskToJson(TaskModel task) => <String, dynamic>{
        'id': task.id,
        'normalizedTitle': task.normalizedTitle,
        'effortBand': task.effortBand,
        'estimatedMinutes': task.estimatedMinutes,
        'category': task.category,
      };

  TaskModel _taskFromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'] as String,
        normalizedTitle: json['normalizedTitle'] as String? ?? 'Task',
        effortBand: json['effortBand'] as String? ?? 'medium',
        estimatedMinutes: json['estimatedMinutes'] as int? ?? 15,
        category: json['category'] as String?,
      );

  Map<String, dynamic> _stepToJson(TaskStepModel step) => <String, dynamic>{
        'id': step.id,
        'taskId': step.taskId,
        'text': step.text,
        'sequenceNo': step.sequenceNo,
        'depthLevel': step.depthLevel,
        'parentStepId': step.parentStepId,
        'isOptional': step.isOptional,
        'isMinimumPath': step.isMinimumPath,
        'status': step.status.name,
      };

  TaskStepModel _stepFromJson(Map<String, dynamic> json) => TaskStepModel(
        id: json['id'] as String,
        taskId: json['taskId'] as String,
        text: json['text'] as String? ?? 'Step',
        sequenceNo: json['sequenceNo'] as int? ?? 0,
        depthLevel: json['depthLevel'] as int? ?? 0,
        parentStepId: json['parentStepId'] as String?,
        isOptional: json['isOptional'] as bool? ?? false,
        isMinimumPath: json['isMinimumPath'] as bool? ?? false,
        status: _stepStatusFromName(json['status'] as String?),
      );

  Map<String, dynamic> _sideQuestToJson(SideQuestModel sideQuest) =>
      <String, dynamic>{
        'id': sideQuest.id,
        'title': sideQuest.title,
        'questType': sideQuest.questType,
        'rewardXp': sideQuest.rewardXp,
        'status': sideQuest.status,
        'taskId': sideQuest.taskId,
        'routineId': sideQuest.routineId,
      };

  SideQuestModel _sideQuestFromJson(Map<String, dynamic> json) =>
      SideQuestModel(
        id: json['id'] as String,
        title: json['title'] as String? ?? 'Side quest',
        questType: json['questType'] as String? ?? 'bonus',
        rewardXp: json['rewardXp'] as int? ?? 10,
        status: json['status'] as String? ?? 'available',
        taskId: json['taskId'] as String?,
        routineId: json['routineId'] as String?,
      );

  StepStatus _stepStatusFromName(String? value) {
    for (final status in StepStatus.values) {
      if (status.name == value) return status;
    }
    return StepStatus.pending;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
