import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/progress_repository_impl.dart';
import '../../providers.dart';

import '../../domain/rewards/user_stats.dart';
import 'progress_view_state.dart';

final progressControllerProvider = StateNotifierProvider<ProgressController,
    AsyncValue<ProgressViewState>>((ref) {
  return ProgressController(
    ref.read(progressRepositoryProvider),
    ref.read(rewardRepositoryProvider),
  );
});

class ProgressController
    extends StateNotifier<AsyncValue<ProgressViewState>> {
  ProgressController(this._repository, this._rewardRepo)
      : super(const AsyncValue.loading());

  final ProgressRepositoryImpl _repository;
  final dynamic _rewardRepo;

  Future<void> load(String userId) async {
    state = const AsyncValue.loading();
    try {
      final stats = await _rewardRepo.getUserStats(userId) as UserStats;
      final logs = await _repository.getRecentProgress(userId);
      final tasks = await _repository.getCompletedTasks(userId);
      final reliability = await _repository.getReliabilityScore(userId);

      state = AsyncValue.data(ProgressViewState(
        stats: stats,
        logs: logs,
        completedTasks: tasks,
        reliabilityScore: reliability,
      ));
    } catch (_) {
      state = AsyncValue.data(ProgressViewState.initial());
    }
  }

  void loadLocalFallback() {
    state = AsyncValue.data(ProgressViewState.initial());
  }
}
