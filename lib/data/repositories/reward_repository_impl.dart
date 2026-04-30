import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/rewards/user_stats.dart';

class RewardRepositoryImpl {
  RewardRepositoryImpl(this._client);

  final SupabaseClient _client;

  Future<UserStats> getUserStats(String userId) async {
    final response = await _client
        .from('rewards')
        .select('amount')
        .eq('user_id', userId)
        .eq('reward_type', 'xp');

    final totalXp = (response as List<dynamic>)
        .fold<int>(0, (sum, row) => sum + (row['amount'] as int? ?? 0));

    // Simple level logic: 1000 XP per level
    final level = (totalXp / 1000).floor() + 1;
    final xpInCurrentLevel = totalXp % 1000;
    final progress = xpInCurrentLevel / 1000;

    // TODO: Implement streak logic based on progress_logs
    const currentStreak = 0;

    return UserStats(
      totalXp: totalXp,
      level: level,
      currentStreak: currentStreak,
      xpToNextLevel: 1000 - xpInCurrentLevel,
      progressToNextLevel: progress,
    );
  }

  Future<void> awardXp({
    required String userId,
    required int amount,
    required String key,
    String? sourceType,
    String? sourceId,
  }) async {
    await _client.from('rewards').insert({
      'user_id': userId,
      'reward_type': 'xp',
      'reward_key': key,
      'amount': amount,
      'source_type': sourceType,
      'source_id': sourceId,
    });
  }
}
