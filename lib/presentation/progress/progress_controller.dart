import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/progress_repository_impl.dart';
import '../../domain/progress/progress_log_model.dart';
import '../../providers.dart';

final progressControllerProvider = StateNotifierProvider<ProgressController,
    AsyncValue<List<ProgressLogModel>>>((ref) {
  return ProgressController(ref.read(progressRepositoryProvider));
});

class ProgressController
    extends StateNotifier<AsyncValue<List<ProgressLogModel>>> {
  ProgressController(this._repository)
      : super(const AsyncValue.data(<ProgressLogModel>[]));

  final ProgressRepositoryImpl _repository;

  Future<void> load(String userId) async {
    state = const AsyncValue.loading();
    try {
      final logs = await _repository.getRecentProgress(userId);
      state = AsyncValue.data(logs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
