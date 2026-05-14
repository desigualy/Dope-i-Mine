import '../../domain/progress/progress_log_model.dart';
import '../../domain/rewards/user_stats.dart';

class ProgressViewState {
  const ProgressViewState({
    required this.stats,
    required this.logs,
    required this.completedTasks,
    required this.reliabilityScore,
  });

  final UserStats stats;
  final List<ProgressLogModel> logs;
  final List<Map<String, dynamic>> completedTasks;
  final int reliabilityScore;

  factory ProgressViewState.initial() => ProgressViewState(
        stats: UserStats.initial(),
        logs: const [],
        completedTasks: const [],
        reliabilityScore: 100,
      );
}
