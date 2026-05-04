import 'reward_points.dart';

class UserStats {
  const UserStats({
    required this.totalXp,
    required this.level,
    required this.currentStreak,
    required this.xpToNextLevel,
    required this.progressToNextLevel,
  });

  final int totalXp;
  final int level;
  final int currentStreak;
  final int xpToNextLevel;
  final double progressToNextLevel;

  int get totalPoints => totalXp;
  int get pointsToNextLevel => xpToNextLevel;

  factory UserStats.initial() => const UserStats(
        totalXp: 0,
        level: 1,
        currentStreak: 0,
        xpToNextLevel: RewardPoints.pointsPerLevel,
        progressToNextLevel: 0,
      );
}
