class SideQuestModel {
  const SideQuestModel({
    required this.id,
    required this.title,
    required this.questType,
    required this.rewardXp,
    required this.status,
    this.taskId,
    this.routineId,
  });

  final String id;
  final String title;
  final String questType;
  final int rewardXp;
  final String status;
  final String? taskId;
  final String? routineId;
}
