import '../tasks/task_step_model.dart';
import 'reward_points.dart';

class PointsEngine {
  const PointsEngine._();

  static bool isCompletableTaskStep(TaskStepModel step) {
    final isUserCompletable = step.isMinimumPath || step.depthLevel > 0;
    return isUserCompletable &&
        !step.isOptional &&
        step.status != StepStatus.skipped;
  }

  static bool isMicroTask(TaskStepModel step) => step.depthLevel > 1;

  static bool allTasksCompleted(List<TaskStepModel> steps) {
    final completable = completableTaskSteps(steps);
    return completable.isNotEmpty &&
        completable.every((step) => step.status == StepStatus.completed);
  }

  static List<TaskStepModel> completableTaskSteps(List<TaskStepModel> steps) {
    return steps
        .where(
          (step) =>
              isCompletableTaskStep(step) || _isLeafTopLevelTask(step, steps),
        )
        .toList(growable: false);
  }

  static bool qualifiesForSideQuest(List<TaskStepModel> steps) {
    return earnedSideQuestCount(steps) > 0;
  }

  static int earnedSideQuestCount(List<TaskStepModel> steps) {
    final completedSteps = steps
        .where((step) =>
            step.depthLevel > 0 &&
            step.status == StepStatus.completed)
        .length;
    return completedSteps ~/ RewardPoints.tasksPerSideQuest;
  }

  static int taskPointsForCompletion(List<TaskStepModel> steps) {
    return completableTaskSteps(steps)
            .where((step) => step.status == StepStatus.completed)
            .length *
        RewardPoints.taskCompleted;
  }

  static int missionPointsForCompletion(List<TaskStepModel> steps) {
    return allTasksCompleted(steps) ? RewardPoints.missionCompleted : 0;
  }

  static bool _isLeafTopLevelTask(
    TaskStepModel step,
    List<TaskStepModel> allSteps,
  ) {
    if (step.depthLevel != 0 || step.isOptional || step.isMinimumPath) {
      return false;
    }
    if (step.status == StepStatus.skipped) return false;
    return !allSteps.any((candidate) => candidate.parentStepId == step.id);
  }
}
