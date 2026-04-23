class ProgressLogModel {
  const ProgressLogModel({
    required this.id,
    required this.eventType,
    required this.createdAt,
    this.taskId,
    this.stepId,
  });

  final String id;
  final String eventType;
  final DateTime createdAt;
  final String? taskId;
  final String? stepId;
}
