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

  SideQuestModel copyWith({
    String? id,
    String? title,
    String? questType,
    int? rewardXp,
    String? status,
    String? taskId,
    String? routineId,
  }) {
    return SideQuestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      questType: questType ?? this.questType,
      rewardXp: rewardXp ?? this.rewardXp,
      status: status ?? this.status,
      taskId: taskId ?? this.taskId,
      routineId: routineId ?? this.routineId,
    );
  }
}
