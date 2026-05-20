enum CaregiverRole { caregiver, overseer, monitor }

enum CaregiverRelationshipStatus {
  pending,
  accepted,
  declined,
  blocked,
  revoked
}

enum CaregiverTaskStatus {
  assigned,
  accepted,
  active,
  completed,
  declined,
  revoked
}

enum CaregiverRoutineStatus { assigned, active, completed, paused, revoked }

enum CaregiverNudgeTone { gentle, practical, reminder }

enum CaregiverEmailInviteStatus { pending, accepted, expired, revoked }

class CaregiverEmailInvite {
  const CaregiverEmailInvite({
    required this.id,
    required this.inviterUserId,
    required this.inviteeEmail,
    required this.role,
    required this.status,
    required this.createdAt,
    this.acceptedUserId,
    this.acceptedAt,
    this.expiresAt,
  });

  final String id;
  final String inviterUserId;
  final String inviteeEmail;
  final CaregiverRole role;
  final CaregiverEmailInviteStatus status;
  final DateTime createdAt;
  final String? acceptedUserId;
  final DateTime? acceptedAt;
  final DateTime? expiresAt;

  factory CaregiverEmailInvite.fromJson(Map<String, dynamic> json) {
    return CaregiverEmailInvite(
      id: json['id'] as String,
      inviterUserId: json['inviter_user_id'] as String,
      inviteeEmail: json['invitee_email'] as String,
      role: CaregiverRole.values.byName(json['role'] as String),
      status:
          CaregiverEmailInviteStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      acceptedUserId: json['accepted_user_id'] as String?,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }
}

class CaregiverRelationship {
  const CaregiverRelationship({
    required this.id,
    required this.caregiverUserId,
    required this.supportedUserId,
    required this.role,
    required this.status,
    this.relationshipLabel,
    required this.createdAt,
    this.acceptedAt,
    this.revokedAt,
    this.caregiverName,
    this.supportedName,
  });

  final String id;
  final String caregiverUserId;
  final String supportedUserId;
  final CaregiverRole role;
  final CaregiverRelationshipStatus status;
  final String? relationshipLabel;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? revokedAt;
  final String? caregiverName;
  final String? supportedName;

  factory CaregiverRelationship.fromJson(Map<String, dynamic> json) {
    return CaregiverRelationship(
      id: json['id'] as String,
      caregiverUserId: json['caregiver_user_id'] as String,
      supportedUserId: json['supported_user_id'] as String,
      role: CaregiverRole.values.byName(json['role'] as String),
      status:
          CaregiverRelationshipStatus.values.byName(json['status'] as String),
      relationshipLabel: json['relationship_label'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
      revokedAt: json['revoked_at'] != null
          ? DateTime.parse(json['revoked_at'] as String)
          : null,
      caregiverName: json['caregiver_name'] as String?,
      supportedName: json['supported_name'] as String?,
    );
  }

  CaregiverRelationship copyWith({
    CaregiverRelationshipStatus? status,
    DateTime? acceptedAt,
    DateTime? revokedAt,
  }) {
    return CaregiverRelationship(
      id: id,
      caregiverUserId: caregiverUserId,
      supportedUserId: supportedUserId,
      role: role,
      status: status ?? this.status,
      relationshipLabel: relationshipLabel,
      createdAt: createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      revokedAt: revokedAt ?? this.revokedAt,
      caregiverName: caregiverName,
      supportedName: supportedName,
    );
  }
}

class CaregiverPermissions {
  const CaregiverPermissions({
    required this.id,
    required this.relationshipId,
    this.canViewTaskTitles = true,
    this.canViewTaskSteps = false,
    this.canViewProgress = true,
    this.canViewMissedRoutines = true,
    this.canViewBodyDoubleSummaries = true,
    this.canViewSafetyAlerts = true,
    this.canAssignTasks = false,
    this.canAssignRoutines = false,
    this.canSetReminders = false,
    this.canSuggestSideQuests = false,
    this.canInviteBodyDouble = false,
    this.canApproveRandomBodyDouble = false,
    this.canArchiveAssignments = false,
    this.onlyViewAssignedTasks = false,
    this.onlyViewCaregiverRoutines = false,
    this.onlyViewSummaries = false,
    this.supportHoursJson,
  });

  final String id;
  final String relationshipId;
  final bool canViewTaskTitles;
  final bool canViewTaskSteps;
  final bool canViewProgress;
  final bool canViewMissedRoutines;
  final bool canViewBodyDoubleSummaries;
  final bool canViewSafetyAlerts;
  final bool canAssignTasks;
  final bool canAssignRoutines;
  final bool canSetReminders;
  final bool canSuggestSideQuests;
  final bool canInviteBodyDouble;
  final bool canApproveRandomBodyDouble;
  final bool canArchiveAssignments;
  final bool onlyViewAssignedTasks;
  final bool onlyViewCaregiverRoutines;
  final bool onlyViewSummaries;
  final Map<String, dynamic>? supportHoursJson;

  factory CaregiverPermissions.fromJson(Map<String, dynamic> json) {
    return CaregiverPermissions(
      id: json['id'] as String,
      relationshipId: json['relationship_id'] as String,
      canViewTaskTitles: json['can_view_task_titles'] as bool? ?? true,
      canViewTaskSteps: json['can_view_task_steps'] as bool? ?? false,
      canViewProgress: json['can_view_progress'] as bool? ?? true,
      canViewMissedRoutines: json['can_view_missed_routines'] as bool? ?? true,
      canViewBodyDoubleSummaries:
          json['can_view_body_double_summaries'] as bool? ?? true,
      canViewSafetyAlerts: json['can_view_safety_alerts'] as bool? ?? true,
      canAssignTasks: json['can_assign_tasks'] as bool? ?? false,
      canAssignRoutines: json['can_assign_routines'] as bool? ?? false,
      canSetReminders: json['can_set_reminders'] as bool? ?? false,
      canSuggestSideQuests: json['can_suggest_side_quests'] as bool? ?? false,
      canInviteBodyDouble: json['can_invite_body_double'] as bool? ?? false,
      canApproveRandomBodyDouble:
          json['can_approve_random_body_double'] as bool? ?? false,
      canArchiveAssignments: json['can_archive_assignments'] as bool? ?? false,
      onlyViewAssignedTasks: json['only_view_assigned_tasks'] as bool? ?? false,
      onlyViewCaregiverRoutines:
          json['only_view_caregiver_routines'] as bool? ?? false,
      onlyViewSummaries: json['only_view_summaries'] as bool? ?? false,
      supportHoursJson: json['support_hours_json'] as Map<String, dynamic>?,
    );
  }
}

class CaregiverAssignedTask {
  const CaregiverAssignedTask({
    required this.id,
    required this.relationshipId,
    required this.caregiverUserId,
    required this.targetUserId,
    required this.taskId,
    required this.taskTitle,
    required this.status,
    this.taskDescription,
    this.steps = const <String>[],
    this.dueAt,
    this.visibilityLevel = 'standard',
    required this.assignedAt,
    this.acceptedAt,
    this.completedAt,
    required this.updatedAt,
  });

  final String id;
  final String relationshipId;
  final String caregiverUserId;
  final String targetUserId;
  final String taskId;
  final String taskTitle;
  final String? taskDescription;
  final List<String> steps;
  final CaregiverTaskStatus status;
  final DateTime? dueAt;
  final String visibilityLevel;
  final DateTime assignedAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime updatedAt;

  factory CaregiverAssignedTask.fromJson(Map<String, dynamic> json) {
    final task = json['task'];
    final rawSteps = json['steps'];
    return CaregiverAssignedTask(
      id: json['id'] as String,
      relationshipId: json['relationship_id'] as String? ?? '',
      caregiverUserId: json['caregiver_user_id'] as String,
      targetUserId: json['target_user_id'] as String,
      taskId: json['task_id'] as String? ?? '',
      taskTitle: json['task_title'] as String? ??
          (task is Map ? task['normalized_title'] as String? : null) ??
          'Support task',
      taskDescription: json['task_description'] as String?,
      steps: rawSteps is List
          ? rawSteps.map((value) => value.toString()).toList(growable: false)
          : const <String>[],
      status: _taskStatusFromName(json['status'] as String? ?? 'assigned'),
      dueAt: json['due_at'] != null
          ? DateTime.parse(json['due_at'] as String)
          : null,
      visibilityLevel: json['visibility_level'] as String? ?? 'standard',
      assignedAt: DateTime.parse(
          json['assigned_at'] as String? ?? json['created_at'] as String),
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      updatedAt: DateTime.parse(json['updated_at'] as String? ??
          json['completed_at'] as String? ??
          json['accepted_at'] as String? ??
          json['assigned_at'] as String? ??
          json['created_at'] as String),
    );
  }
}

class CaregiverAssignedRoutine {
  const CaregiverAssignedRoutine({
    required this.id,
    required this.relationshipId,
    required this.caregiverUserId,
    required this.targetUserId,
    this.routineId,
    required this.routineTitle,
    required this.schedule,
    required this.status,
    required this.assignedAt,
    this.startedAt,
    this.completedAt,
    required this.updatedAt,
  });

  final String id;
  final String relationshipId;
  final String caregiverUserId;
  final String targetUserId;
  final String? routineId;
  final String routineTitle;
  final String schedule;
  final CaregiverRoutineStatus status;
  final DateTime assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime updatedAt;

  factory CaregiverAssignedRoutine.fromJson(Map<String, dynamic> json) {
    final routine = json['routine'];
    return CaregiverAssignedRoutine(
      id: json['id'] as String,
      relationshipId: json['relationship_id'] as String? ?? '',
      caregiverUserId: json['caregiver_user_id'] as String,
      targetUserId: json['target_user_id'] as String,
      routineId: json['routine_id'] as String?,
      routineTitle: json['routine_title'] as String? ??
          (routine is Map ? routine['title'] as String? : null) ??
          'Shared routine',
      schedule: json['schedule'] as String? ?? 'Flexible',
      status: _routineStatusFromName(json['status'] as String? ?? 'assigned'),
      assignedAt: DateTime.parse(
          json['assigned_at'] as String? ?? json['created_at'] as String),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      updatedAt: DateTime.parse(json['updated_at'] as String? ??
          json['completed_at'] as String? ??
          json['started_at'] as String? ??
          json['assigned_at'] as String? ??
          json['created_at'] as String),
    );
  }
}

class CaregiverNudge {
  const CaregiverNudge({
    required this.id,
    required this.relationshipId,
    required this.caregiverUserId,
    required this.supportedUserId,
    required this.message,
    required this.tone,
    required this.createdAt,
    this.readAt,
  });

  final String id;
  final String relationshipId;
  final String caregiverUserId;
  final String supportedUserId;
  final String message;
  final CaregiverNudgeTone tone;
  final DateTime createdAt;
  final DateTime? readAt;

  factory CaregiverNudge.fromJson(Map<String, dynamic> json) {
    return CaregiverNudge(
      id: json['id'] as String,
      relationshipId: json['relationship_id'] as String,
      caregiverUserId: json['caregiver_user_id'] as String? ??
          json['sender_id'] as String? ??
          '',
      supportedUserId: json['supported_user_id'] as String? ??
          json['receiver_id'] as String? ??
          '',
      message: json['message'] as String,
      tone:
          CaregiverNudgeTone.values.byName(json['tone'] as String? ?? 'gentle'),
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
    );
  }
}

CaregiverTaskStatus _taskStatusFromName(String name) {
  if (name == 'suggested') return CaregiverTaskStatus.assigned;
  if (name == 'archived') return CaregiverTaskStatus.revoked;
  return CaregiverTaskStatus.values.byName(name);
}

CaregiverRoutineStatus _routineStatusFromName(String name) {
  if (name == 'archived') return CaregiverRoutineStatus.revoked;
  return CaregiverRoutineStatus.values.byName(name);
}
