import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/routines/routine_model.dart';
import '../../domain/routines/routine_step_model.dart';
import '../../providers.dart';

class RoutineRunState {
  const RoutineRunState({
    this.routine,
    this.steps = const <RoutineStepModel>[],
    this.currentIndex = 0,
    this.completedStepIds = const <String>{},
    this.loading = false,
  });

  final RoutineModel? routine;
  final List<RoutineStepModel> steps;
  final int currentIndex;
  final Set<String> completedStepIds;
  final bool loading;

  bool get isComplete =>
      steps.isNotEmpty && completedStepIds.length >= steps.length;

  RoutineStepModel? get currentStep {
    if (steps.isEmpty || currentIndex < 0 || currentIndex >= steps.length) {
      return null;
    }
    return steps[currentIndex];
  }

  RoutineRunState copyWith({
    RoutineModel? routine,
    bool clearRoutine = false,
    List<RoutineStepModel>? steps,
    int? currentIndex,
    Set<String>? completedStepIds,
    bool? loading,
  }) {
    return RoutineRunState(
      routine: clearRoutine ? null : (routine ?? this.routine),
      steps: steps ?? this.steps,
      currentIndex: currentIndex ?? this.currentIndex,
      completedStepIds: completedStepIds ?? this.completedStepIds,
      loading: loading ?? this.loading,
    );
  }
}

final routineRunControllerProvider =
    StateNotifierProvider<RoutineRunController, RoutineRunState>((ref) {
  return RoutineRunController(ref);
});

class RoutineRunController extends StateNotifier<RoutineRunState> {
  RoutineRunController([this._ref]) : super(const RoutineRunState());

  final Ref? _ref;

  void start({
    RoutineModel? routine,
    required List<RoutineStepModel> steps,
  }) {
    state = RoutineRunState(
      routine: routine,
      steps: steps,
      currentIndex: 0,
      completedStepIds: <String>{},
    );
  }

  Future<void> completeCurrent() async {
    if (state.steps.isEmpty || state.isComplete) return;
    final currentStep = state.currentStep;
    if (currentStep == null) return;

    final ref = _ref;
    if (ref != null) {
      final authUser = ref.read(authRepositoryProvider).getCurrentUser();
      if (authUser != null) {
        await ref.read(routineRepositoryProvider).completeStep(
              userId: authUser.id,
              routineId: currentStep.routineId,
              stepId: currentStep.id,
            );
      }
    }

    final updatedCompleted = <String>{
      ...state.completedStepIds,
      currentStep.id,
    };
    final complete = updatedCompleted.length >= state.steps.length;
    final nextIndex = complete
        ? state.currentIndex
        : (state.currentIndex < state.steps.length - 1
            ? state.currentIndex + 1
            : state.currentIndex);

    state = state.copyWith(
      completedStepIds: updatedCompleted,
      currentIndex: nextIndex,
    );
  }

  void goBack() {
    if (state.currentIndex == 0) return;
    state = state.copyWith(currentIndex: state.currentIndex - 1);
  }

  void resetCurrentRun() {
    if (state.routine == null || state.steps.isEmpty) return;
    state = state.copyWith(
      currentIndex: 0,
      completedStepIds: <String>{},
    );
  }

  void clear() {
    state = const RoutineRunState();
  }
}
