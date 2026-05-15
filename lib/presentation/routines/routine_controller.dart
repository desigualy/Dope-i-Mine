import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/routine_repository_impl.dart';
import '../../data/repositories/routine_templates.dart';
import '../../domain/routines/routine_model.dart';
import '../../domain/routines/routine_step_model.dart';
import '../../providers.dart';

final routineControllerProvider = StateNotifierProvider<RoutineController,
    AsyncValue<List<RoutineModel>>>((ref) {
  return RoutineController(ref.read(routineRepositoryProvider));
});

final selectedRoutineProvider = StateProvider<RoutineModel?>((ref) => null);
final selectedRoutineStepsProvider =
    StateProvider<List<RoutineStepModel>>((ref) => const <RoutineStepModel>[]);
final routineDraftTemplateProvider =
    StateProvider<RoutineTemplate?>((ref) => null);
final savedTaskRoutineTemplatesProvider =
    StateProvider<List<RoutineTemplate>>((ref) => const <RoutineTemplate>[]);

class RoutineController extends StateNotifier<AsyncValue<List<RoutineModel>>> {
  RoutineController(this._repository)
      : super(const AsyncValue.data(<RoutineModel>[]));

  final RoutineRepositoryImpl _repository;

  Future<void> load(String userId) async {
    state = const AsyncValue.loading();
    try {
      final routines = await _repository.getRoutines(userId);
      state = AsyncValue.data(routines);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<RoutineModel> create({
    required String userId,
    required String title,
    required String ageBand,
    required List<String> steps,
  }) async {
    final routine = await _repository.createRoutine(
      userId: userId,
      title: title,
      ageBand: ageBand,
      initialSteps: steps,
    );
    await load(userId);
    return routine;
  }

  Future<void> update({
    required String userId,
    required String routineId,
    required String title,
    required String ageBand,
    required List<String> steps,
  }) async {
    await _repository.updateRoutine(
      routineId: routineId,
      title: title,
      ageBand: ageBand,
    );
    await _repository.replaceRoutineSteps(routineId: routineId, steps: steps);
    await load(userId);
  }

  Future<void> delete({
    required String userId,
    required String routineId,
  }) async {
    await _repository.deleteRoutine(routineId);
    await load(userId);
  }

  Future<RoutineModel> duplicate({
    required String userId,
    required RoutineModel source,
  }) async {
    final routine = await _repository.duplicateRoutine(
      userId: userId,
      source: source,
    );
    await load(userId);
    return routine;
  }

  Future<List<RoutineStepModel>> loadSteps(String routineId) {
    return _repository.getRoutineSteps(routineId);
  }
}
