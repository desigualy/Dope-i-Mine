import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/rewards/points_engine.dart';
import '../../domain/rewards/reward_points.dart';
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
    this.showSideQuests = true,
    this.sideQuestsEnabled = true,
    this.focusedSectionId,
    this.missionRewarded = false,
    this.snapshot,
  });

  final bool loading;
  final TaskModel? task;
  final List<TaskStepModel> steps;
  final List<TaskStepModel> minimumVersion;
  final List<SideQuestModel> sideQuests;
  final bool showMinimumVersion;
  final bool showSideQuests;
  final bool sideQuestsEnabled;
  final String? focusedSectionId;
  final bool missionRewarded;
  final TaskStateSnapshot? snapshot;

  TaskViewState copyWith({
    bool? loading,
    TaskModel? task,
    List<TaskStepModel>? steps,
    List<TaskStepModel>? minimumVersion,
    List<SideQuestModel>? sideQuests,
    bool? showMinimumVersion,
    bool? showSideQuests,
    bool? sideQuestsEnabled,
    String? focusedSectionId,
    bool? missionRewarded,
    TaskStateSnapshot? snapshot,
    bool clearFocusedSection = false,
  }) {
    return TaskViewState(
      loading: loading ?? this.loading,
      task: task ?? this.task,
      steps: steps ?? this.steps,
      minimumVersion: minimumVersion ?? this.minimumVersion,
      sideQuests: sideQuests ?? this.sideQuests,
      showMinimumVersion: showMinimumVersion ?? this.showMinimumVersion,
      showSideQuests: showSideQuests ?? this.showSideQuests,
      sideQuestsEnabled: sideQuestsEnabled ?? this.sideQuestsEnabled,
      focusedSectionId: clearFocusedSection
          ? null
          : (focusedSectionId ?? this.focusedSectionId),
      missionRewarded: missionRewarded ?? this.missionRewarded,
      snapshot: snapshot ?? this.snapshot,
    );
  }
}

final taskControllerProvider =
    StateNotifierProvider<TaskController, TaskViewState>((ref) {
  return TaskController(ref.read(taskRepositoryProvider));
});

class TaskController extends StateNotifier<TaskViewState> {
  TaskController(this._repository) : super(const TaskViewState());

  final dynamic _repository;

  Future<void> createTask({
    required String userId,
    required String sourceText,
    required TaskStateSnapshot snapshot,
    required bool sideQuestsEnabled,
  }) async {
    state = TaskViewState(
      loading: true,
      snapshot: snapshot,
      sideQuestsEnabled: sideQuestsEnabled,
      showSideQuests: sideQuestsEnabled,
    );
    try {
      final result = await _repository.createTask(
        userId: userId,
        sourceText: sourceText,
        snapshot: snapshot,
        sideQuestsEnabled: sideQuestsEnabled,
      );
      state = state.copyWith(
        loading: false,
        task: result.task,
        steps: result.steps,
        minimumVersion: result.minimumVersion,
        sideQuests: sideQuestsEnabled
            ? _lockedSideQuests(result.sideQuests)
            : const <SideQuestModel>[],
        showMinimumVersion: false,
        showSideQuests: sideQuestsEnabled,
        sideQuestsEnabled: sideQuestsEnabled,
        missionRewarded: false,
        snapshot: snapshot,
      );
    } catch (_) {
      state = state.copyWith(loading: false);
      rethrow;
    }
  }

  void toggleMinimumVersion(bool value) {
    state = state.copyWith(showMinimumVersion: value);
  }

  void toggleSideQuests(bool value) {
    if (!state.sideQuestsEnabled) return;
    state = state.copyWith(showSideQuests: value);
  }

  void setFocusedSection(String sectionId) {
    state = state.copyWith(focusedSectionId: sectionId);
  }

  void clearFocusedSection() {
    state = state.copyWith(clearFocusedSection: true);
  }

  void replaceSteps(List<TaskStepModel> steps) {
    state = state.copyWith(steps: steps);
  }

  void replaceSideQuests(List<SideQuestModel> sideQuests) {
    if (!state.sideQuestsEnabled) return;
    state = state.copyWith(sideQuests: sideQuests);
  }

  void replaceStepWithSubsteps({
    required String stepId,
    required List<TaskStepModel> substeps,
    required bool isMinimumVersion,
  }) {
    if (substeps.isEmpty) return;

    if (isMinimumVersion) {
      final current = state.minimumVersion;
      final existingIds = current.map((step) => step.id).toSet();
      final additions =
          substeps.where((step) => !existingIds.contains(step.id)).toList();
      if (additions.isNotEmpty) {
        state = state.copyWith(
            minimumVersion: <TaskStepModel>[...current, ...additions]);
      }
    } else {
      final current = state.steps;
      final existingIds = current.map((step) => step.id).toSet();
      final additions =
          substeps.where((step) => !existingIds.contains(step.id)).toList();
      if (additions.isNotEmpty) {
        state =
            state.copyWith(steps: <TaskStepModel>[...current, ...additions]);
        _unlockBreakdownSideQuest();
      }
    }
  }

  void _unlockBreakdownSideQuest() {
    if (!state.sideQuestsEnabled) return;
    final locked = state.sideQuests.where((q) => q.status == 'locked').toList();
    if (locked.isEmpty) return;

    final updated = state.sideQuests.map<SideQuestModel>((q) {
      if (q.id == locked.first.id) {
        return q.copyWith(
          status: 'available',
          rewardXp: RewardPoints.sideQuestBreakdown,
        );
      }
      return q;
    }).toList();

    state = state.copyWith(sideQuests: updated);
  }

  void updateStepCompletion(String stepId, String status) {
    final stepStatus = _statusFromString(status);
    final updatedSteps = state.steps.map<TaskStepModel>((step) {
      if (step.id == stepId) {
        return step.copyWith(status: stepStatus);
      }
      return step;
    }).toList();

    final updatedMinimumVersion = state.minimumVersion.map<TaskStepModel>((step) {
      if (step.id == stepId) {
        return step.copyWith(status: stepStatus);
      }
      return step;
    }).toList();

    state = state.copyWith(
      steps: updatedSteps,
      minimumVersion: updatedMinimumVersion,
    );

    if (stepStatus == StepStatus.completed) {
      unlockEarnedSideQuests(updatedSteps);
    }
  }

  void updateSideQuestStatus(String sideQuestId, String status) {
    if (!state.sideQuestsEnabled) return;
    final updatedSideQuests = state.sideQuests.map<SideQuestModel>((quest) {
      if (quest.id == sideQuestId) {
        return quest.copyWith(status: status);
      }
      return quest;
    }).toList();

    state = state.copyWith(sideQuests: updatedSideQuests);
  }

  List<SideQuestModel> unlockEarnedSideQuests(List<TaskStepModel> rewardSteps) {
    if (!state.sideQuestsEnabled) return const <SideQuestModel>[];
    final earnedCount = PointsEngine.earnedSideQuestCount(rewardSteps);
    if (earnedCount <= 0 || state.sideQuests.isEmpty) {
      return const <SideQuestModel>[];
    }

    var unlockedOrFinishedCount = 0;
    final updatedSideQuests = state.sideQuests.map<SideQuestModel>((quest) {
      final alreadyEarned = quest.status == 'available' ||
          quest.status == 'accepted' ||
          quest.status == 'completed';
      if (alreadyEarned) {
        unlockedOrFinishedCount++;
        return quest;
      }
      if (quest.status == 'locked' && unlockedOrFinishedCount < earnedCount) {
        unlockedOrFinishedCount++;
        return quest.copyWith(
          status: 'available',
          rewardXp: RewardPoints.sideQuestCompleted,
        );
      }
      return quest;
    }).toList();

    state = state.copyWith(sideQuests: updatedSideQuests);
    return const <SideQuestModel>[]; // Return empty as we update state directly
  }

  Future<void> completeNextStep() async {
    final nextStep = state.steps.firstWhere(
      (step) => step.depthLevel > 0 && step.status != StepStatus.completed,
      orElse: () => state.steps.first, // Fallback
    );
    if (nextStep.status == StepStatus.completed) return;

    updateStepCompletion(nextStep.id, 'completed');
  }

  void markMissionRewarded() {
    state = state.copyWith(missionRewarded: true);
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

  List<SideQuestModel> _lockedSideQuests(List<dynamic> sideQuests) {
    return sideQuests
        .whereType<SideQuestModel>()
        .map((quest) => quest.copyWith(status: 'locked'))
        .toList();
  }
}
