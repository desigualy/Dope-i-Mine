class CaregiverAssignedRoutineModel {
  const CaregiverAssignedRoutineModel({
    required this.id,
    required this.relationshipId,
    required this.caregiverUserId,
    required this.targetUserId,
    this.routineId,
    required this.routineTitle,
    required this.schedule,
    required this.status,
  });

  final String id;
  final String relationshipId;
  final String caregiverUserId;
  final String targetUserId;
  final String? routineId;
  final String routineTitle;
  final String schedule;
  final String status;
}
