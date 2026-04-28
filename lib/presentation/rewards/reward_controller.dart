import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/reward_repository_impl.dart';
import '../../domain/rewards/user_stats.dart';
import '../../providers.dart';

final rewardControllerProvider =
    StateNotifierProvider<RewardController, AsyncValue<UserStats>>((ref) {
  return RewardController(ref.read(rewardRepositoryProvider));
});

class RewardController extends StateNotifier<AsyncValue<UserStats>> {
  RewardController(this._repository) : super(const AsyncValue.loading());

  final RewardRepositoryImpl _repository;

  Future<void> loadStats(String userId) async {
    state = const AsyncValue.loading();
    try {
      final stats = await _repository.getUserStats(userId);
      state = AsyncValue.data(stats);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refreshStats(String userId) async {
    try {
      final stats = await _repository.getUserStats(userId);
      state = AsyncValue.data(stats);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
