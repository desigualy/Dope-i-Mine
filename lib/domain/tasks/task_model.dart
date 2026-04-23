class TaskModel {
  const TaskModel({
    required this.id,
    required this.normalizedTitle,
    required this.effortBand,
    required this.estimatedMinutes,
    this.category,
  });

  final String id;
  final String normalizedTitle;
  final String effortBand;
  final int estimatedMinutes;
  final String? category;
}
