import '../../domain/caregiver/caregiver_models.dart';
import '../../domain/body_double/body_double_session.dart';

abstract class CaregiverRepository {
  Future<List<CaregiverRelationship>> loadRelationships();
  Future<List<CaregiverEmailInvite>> loadEmailInvites();
  Future<void> cancelEmailInvite(String inviteId);
  Future<CaregiverRelationship?> createRelationshipRequest({
    required String targetUserEmail,
    required CaregiverRole role,
    String? label,
  });
  Future<CaregiverEmailInvite?> createEmailInvite({
    required String targetUserEmail,
    required CaregiverRole role,
    required String temporaryPassword,
  });
  Future<CaregiverRelationship?> acceptEmailInvite(String inviteId);
  Future<void> respondToRelationshipRequest({
    required String relationshipId,
    required bool accept,
  });
  Future<void> revokeRelationship(String relationshipId);

  Future<CaregiverPermissions?> loadPermissions(String relationshipId);
  Future<void> updatePermissions(CaregiverPermissions permissions);

  Future<List<CaregiverAssignedTask>> loadAssignedTasks({String? targetUserId});
  Future<void> assignTask({
    required String targetUserId,
    required String taskTitle,
    String? taskDescription,
    List<String>? steps,
    DateTime? dueAt,
    String visibilityLevel = 'standard',
  });
  Future<void> respondToAssignedTask({
    required String assignedTaskId,
    required CaregiverTaskStatus status,
  });
  Future<List<CaregiverAssignedRoutine>> loadAssignedRoutines(
      {String? targetUserId});
  Future<void> assignRoutine({
    required String targetUserId,
    String? routineId,
    required String routineTitle,
    String schedule,
  });
  Future<void> respondToAssignedRoutine({
    required String assignedRoutineId,
    required CaregiverRoutineStatus status,
  });

  Future<void> suggestSideQuest({
    required String targetUserId,
    required String title,
  });

  Future<void> sendNudge({
    required String relationshipId,
    required String targetUserId,
    required String message,
    CaregiverNudgeTone tone,
  });

  Future<void> setMinorRandomApproval({
    required String targetUserId,
    required bool approved,
  });

  Future<void> inviteToBodyDouble({
    required String targetUserId,
    required String taskCategory,
    int durationMinutes = 25,
  });

  Future<List<CaregiverAlert>> loadAlerts(String relationshipId);
  Future<List<BodyDoubleSession>> loadBodyDoubleSummaries(String userId);
  Future<String> exportProgressReport(String userId);
}

class CaregiverAlert {
  const CaregiverAlert({
    required this.id,
    required this.relationshipId,
    required this.alertType,
    required this.severity,
    required this.title,
    this.body,
    required this.createdAt,
    this.acknowledgedAt,
  });

  final String id;
  final String relationshipId;
  final String alertType;
  final String severity;
  final String title;
  final String? body;
  final DateTime createdAt;
  final DateTime? acknowledgedAt;

  factory CaregiverAlert.fromJson(Map<String, dynamic> json) {
    return CaregiverAlert(
      id: json['id'] as String,
      relationshipId: json['relationship_id'] as String,
      alertType: json['alert_type'] as String,
      severity: json['severity'] as String? ?? 'info',
      title: json['title'] as String,
      body: json['body'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      acknowledgedAt: json['acknowledged_at'] != null
          ? DateTime.parse(json['acknowledged_at'] as String)
          : null,
    );
  }
}
