import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/routines/routine_step_model.dart';

class RoutineRunState {
  const RoutineRunState({
    this.steps = const <RoutineStepModel>[],
    this.currentIndex = 0,
    this.completedStepIds = const <String>{},
    this.loading = false,
  });

  final List<RoutineStepModel> steps;
  final int currentIndex;
  final Set<String> completedStepIds;
  final bool loading;

  RoutineRunState copyWith({
    List<RoutineStepModel>? steps,
    int? currentIndex,
    Set<String>? completedStepIds,
    bool? loading,
  }) {
    return RoutineRunState(
      steps: steps ?? this.steps,
      currentIndex: currentIndex ?? this.currentIndex,
      completedStepIds: completedStepIds ?? this.completedStepIds,
      loading: loading ?? this.loading,
    );
  }
}

final routineRunControllerProvider =
    StateNotifierProvider<RoutineRunController, RoutineRunState>((ref) {
  return RoutineRunController();
});

class RoutineRunController extends StateNotifier<RoutineRunState> {
  RoutineRunController() : super(const RoutineRunState());

  void start(List<RoutineStepModel> steps) {
    state = state.copyWith(
      steps: steps,
      currentIndex: 0,
      completedStepIds: <String>{},
    );
  }

  void completeCurrent() {
    if (state.steps.isEmpty) return;
    final currentStep = state.steps[state.currentIndex];
    final updatedCompleted = <String>{
      ...state.completedStepIds,
      currentStep.id,
    };
    final nextIndex = state.currentIndex < state.steps.length - 1
        ? state.currentIndex + 1
        : state.currentIndex;
    state = state.copyWith(
      completedStepIds: updatedCompleted,
      currentIndex: nextIndex,
    );
  }

  void goBack() {
    if (state.currentIndex == 0) return;
    state = state.copyWith(currentIndex: state.currentIndex - 1);
  }
}
