import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskSessionState {
  const TaskSessionState({
    this.paused = false,
    this.currentStepIndex = 0,
    this.showOnlyCurrentStep = false,
  });

  final bool paused;
  final int currentStepIndex;
  final bool showOnlyCurrentStep;

  TaskSessionState copyWith({
    bool? paused,
    int? currentStepIndex,
    bool? showOnlyCurrentStep,
  }) {
    return TaskSessionState(
      paused: paused ?? this.paused,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      showOnlyCurrentStep: showOnlyCurrentStep ?? this.showOnlyCurrentStep,
    );
  }
}

final taskSessionControllerProvider =
    StateNotifierProvider<TaskSessionController, TaskSessionState>((ref) {
  return TaskSessionController();
});

class TaskSessionController extends StateNotifier<TaskSessionState> {
  TaskSessionController() : super(const TaskSessionState());

  void pause() => state = state.copyWith(paused: true);

  void resume() => state = state.copyWith(paused: false);

  void nextStep() =>
      state = state.copyWith(currentStepIndex: state.currentStepIndex + 1);

  void showFirstStepOnly() =>
      state = state.copyWith(showOnlyCurrentStep: true, currentStepIndex: 0);
}
