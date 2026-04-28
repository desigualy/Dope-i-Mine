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

  factory UserStats.initial() => const UserStats(
        totalXp: 0,
        level: 1,
        currentStreak: 0,
        xpToNextLevel: 1000,
        progressToNextLevel: 0,
      );
}
