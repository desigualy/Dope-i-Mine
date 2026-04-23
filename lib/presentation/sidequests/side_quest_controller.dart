import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/side_quest_repository_impl.dart';
import '../../domain/sidequests/side_quest_model.dart';
import '../../providers.dart';

final sideQuestControllerProvider = StateNotifierProvider<SideQuestController,
    AsyncValue<List<SideQuestModel>>>((ref) {
  return SideQuestController(ref.read(sideQuestRepositoryProvider));
});

class SideQuestController
    extends StateNotifier<AsyncValue<List<SideQuestModel>>> {
  SideQuestController(this._repository)
      : super(const AsyncValue.data(<SideQuestModel>[]));

  final SideQuestRepositoryImpl _repository;

  Future<void> loadForTask({
    required String userId,
    required String taskId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final quests = await _repository.getAvailableForTask(userId, taskId);
      state = AsyncValue.data(quests);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
