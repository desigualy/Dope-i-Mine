import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/task_repository_impl.dart';
import '../../domain/tasks/task_model.dart';
import '../../domain/tasks/task_state_snapshot.dart';
import '../../domain/tasks/task_step_model.dart';
import '../../domain/sidequests/side_quest_model.dart';
import '../../providers.dart';

class TaskViewState {
  const TaskViewState({
    this.loading = false,
    this.task,
    this.steps = const <TaskStepModel>[],
    this.minimumVersion = const <TaskStepModel>[],
    this.sideQuests = const <SideQuestModel>[],
    this.showMinimumVersion = false,
  });

  final bool loading;
  final TaskModel? task;
  final List<TaskStepModel> steps;
  final List<TaskStepModel> minimumVersion;
  final List<SideQuestModel> sideQuests;
  final bool showMinimumVersion;

  TaskViewState copyWith({
    bool? loading,
    TaskModel? task,
    List<TaskStepModel>? steps,
    List<TaskStepModel>? minimumVersion,
    List<SideQuestModel>? sideQuests,
    bool? showMinimumVersion,
  }) {
    return TaskViewState(
      loading: loading ?? this.loading,
      task: task ?? this.task,
      steps: steps ?? this.steps,
      minimumVersion: minimumVersion ?? this.minimumVersion,
      sideQuests: sideQuests ?? this.sideQuests,
      showMinimumVersion: showMinimumVersion ?? this.showMinimumVersion,
    );
  }
}

final taskControllerProvider =
    StateNotifierProvider<TaskController, TaskViewState>((ref) {
  return TaskController(ref.read(taskRepositoryProvider));
});

class TaskController extends StateNotifier<TaskViewState> {
  TaskController(this._repository) : super(const TaskViewState());

  final TaskRepositoryImpl _repository;

  Future<void> createTask({
    required String userId,
    required String sourceText,
    required TaskStateSnapshot snapshot,
  }) async {
    state = const TaskViewState(loading: true);
    try {
      final result = await _repository.createTask(
        userId: userId,
        sourceText: sourceText,
        snapshot: snapshot,
      );
      state = state.copyWith(
        loading: false,
        task: result.task,
        steps: result.steps,
        minimumVersion: result.minimumVersion,
        sideQuests: result.sideQuests,
        showMinimumVersion: false,
      );
    } catch (_) {
      state = state.copyWith(loading: false);
      rethrow;
    }
  }

  void toggleMinimumVersion(bool value) {
    state = state.copyWith(showMinimumVersion: value);
  }

  void replaceSteps(List<TaskStepModel> steps) {
    state = state.copyWith(steps: steps);
  }

  void replaceStepWithSubsteps({
    required String stepId,
    required List<TaskStepModel> substeps,
    required bool isMinimumVersion,
  }) {
    if (isMinimumVersion) {
      final current = state.minimumVersion;
      final index = current.indexWhere((s) => s.id == stepId);
      if (index != -1) {
        final updated = List<TaskStepModel>.from(current);
        updated.removeAt(index);
        updated.insertAll(index, substeps);
        state = state.copyWith(minimumVersion: updated);
      }
    } else {
      final current = state.steps;
      final index = current.indexWhere((s) => s.id == stepId);
      if (index != -1) {
        final updated = List<TaskStepModel>.from(current);
        updated.removeAt(index);
        updated.insertAll(index, substeps);
        state = state.copyWith(steps: updated);
      }
    }
  }

  void updateStepCompletion(String stepId, String status) {
    final stepStatus = _statusFromString(status);
    final updatedSteps = state.steps.map((step) {
      if (step.id == stepId) {
        return step.copyWith(status: stepStatus);
      }
      return step;
    }).toList();

    final updatedMinimumVersion = state.minimumVersion.map((step) {
      if (step.id == stepId) {
        return step.copyWith(status: stepStatus);
      }
      return step;
    }).toList();

    state = state.copyWith(
      steps: updatedSteps,
      minimumVersion: updatedMinimumVersion,
    );
  }

  StepStatus _statusFromString(String status) {
    switch (status) {
      case 'active':
        return StepStatus.active;
      case 'completed':
        return StepStatus.completed;
      case 'skipped':
        return StepStatus.skipped;
      case 'paused':
        return StepStatus.paused;
      default:
        return StepStatus.pending;
    }
  }
}
