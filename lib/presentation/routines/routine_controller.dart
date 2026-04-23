import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/routine_repository_impl.dart';
import '../../domain/routines/routine_model.dart';
import '../../providers.dart';

final routineControllerProvider = StateNotifierProvider<RoutineController,
    AsyncValue<List<RoutineModel>>>((ref) {
  return RoutineController(ref.read(routineRepositoryProvider));
});

class RoutineController
    extends StateNotifier<AsyncValue<List<RoutineModel>>> {
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

  Future<void> create({
    required String userId,
    required String title,
    required String ageBand,
    required List<String> steps,
  }) async {
    await _repository.createRoutine(
      userId: userId,
      title: title,
      ageBand: ageBand,
      initialSteps: steps,
    );
    await load(userId);
  }
}
