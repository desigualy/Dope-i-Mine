class CaregiverAssignedRoutineModel {
  const CaregiverAssignedRoutineModel({
    required this.id,
    required this.caregiverUserId,
    required this.targetUserId,
    required this.routineId,
    required this.status,
  });

  final String id;
  final String caregiverUserId;
  final String targetUserId;
  final String routineId;
  final String status;
}
