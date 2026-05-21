enum BodyDoubleReportStatus { pending, reviewed, actioned, dismissed }

extension BodyDoubleReportStatusLabel on BodyDoubleReportStatus {
  String get value => name;

  static BodyDoubleReportStatus fromValue(String? value) {
    return BodyDoubleReportStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => BodyDoubleReportStatus.pending,
    );
  }
}

enum BodyDoubleRestrictionType { randomSuspended, bodyDoubleSuspended }

extension BodyDoubleRestrictionTypeLabel on BodyDoubleRestrictionType {
  String get value {
    switch (this) {
      case BodyDoubleRestrictionType.randomSuspended:
        return 'random_suspended';
      case BodyDoubleRestrictionType.bodyDoubleSuspended:
        return 'body_double_suspended';
    }
  }

  String get label {
    switch (this) {
      case BodyDoubleRestrictionType.randomSuspended:
        return 'Random matching suspended';
      case BodyDoubleRestrictionType.bodyDoubleSuspended:
        return 'Body double access suspended';
    }
  }

  static BodyDoubleRestrictionType fromValue(String? value) {
    return BodyDoubleRestrictionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => BodyDoubleRestrictionType.randomSuspended,
    );
  }
}

enum BodyDoubleRestrictionStatus { active, expired, revoked }

extension BodyDoubleRestrictionStatusLabel on BodyDoubleRestrictionStatus {
  String get value => name;

  static BodyDoubleRestrictionStatus fromValue(String? value) {
    return BodyDoubleRestrictionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => BodyDoubleRestrictionStatus.active,
    );
  }
}

class BodyDoubleSafetyUserSummary {
  const BodyDoubleSafetyUserSummary({
    required this.userId,
    this.displayName,
    this.ageBand,
    this.reliabilityScore,
  });

  final String? userId;
  final String? displayName;
  final String? ageBand;
  final double? reliabilityScore;

  String get safeLabel {
    final suffix = userId == null || userId!.length < 8
        ? 'unknown'
        : userId!.substring(0, 8);
    final name = displayName?.trim();
    return name == null || name.isEmpty ? 'User $suffix' : '$name ($suffix)';
  }

  factory BodyDoubleSafetyUserSummary.fromJson(
    String? userId,
    Map<String, dynamic>? json,
  ) {
    final score = json?['reliability_score'];
    return BodyDoubleSafetyUserSummary(
      userId: userId,
      displayName: json?['display_name'] as String?,
      ageBand: json?['age_band'] as String?,
      reliabilityScore: score is num ? score.toDouble() : null,
    );
  }
}

class BodyDoubleModerationReport {
  const BodyDoubleModerationReport({
    required this.id,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.details,
    this.reporter,
    this.reported,
    this.sessionId,
  });

  final String id;
  final String reason;
  final String? details;
  final BodyDoubleReportStatus status;
  final DateTime? createdAt;
  final BodyDoubleSafetyUserSummary? reporter;
  final BodyDoubleSafetyUserSummary? reported;
  final String? sessionId;

  bool get isPending => status == BodyDoubleReportStatus.pending;

  factory BodyDoubleModerationReport.fromJson(Map<String, dynamic> json) {
    return BodyDoubleModerationReport(
      id: json['id'] as String? ?? '',
      reason: json['reason'] as String? ?? 'Safety concern',
      details: json['details'] as String?,
      status: BodyDoubleReportStatusLabel.fromValue(json['status'] as String?),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      sessionId: json['session_id'] as String?,
      reporter: BodyDoubleSafetyUserSummary.fromJson(
        json['reporter_id'] as String?,
        _mapOrNull(json['reporter_profile']),
      ),
      reported: BodyDoubleSafetyUserSummary.fromJson(
        json['reported_id'] as String?,
        _mapOrNull(json['reported_profile']),
      ),
    );
  }
}

class BodyDoubleModerationSessionSummary {
  const BodyDoubleModerationSessionSummary({
    required this.id,
    this.mode,
    this.status,
    this.sessionType,
    this.communicationMode,
    this.privacyLevel,
    this.startedAt,
    this.endedAt,
  });

  final String id;
  final String? mode;
  final String? status;
  final String? sessionType;
  final String? communicationMode;
  final String? privacyLevel;
  final DateTime? startedAt;
  final DateTime? endedAt;

  factory BodyDoubleModerationSessionSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return BodyDoubleModerationSessionSummary(
      id: json['id'] as String? ?? '',
      mode: json['mode'] as String?,
      status: json['status'] as String?,
      sessionType: json['session_type'] as String?,
      communicationMode: json['communication_mode'] as String?,
      privacyLevel: json['privacy_level'] as String?,
      startedAt: DateTime.tryParse(json['started_at'] as String? ?? ''),
      endedAt: DateTime.tryParse(json['ended_at'] as String? ?? ''),
    );
  }
}

class BodyDoubleModerationEvent {
  const BodyDoubleModerationEvent({
    required this.id,
    this.sessionId,
    this.senderId,
    this.reportId,
    this.action,
    this.reason,
    this.bodyPreview,
    this.createdAt,
  });

  final String id;
  final String? sessionId;
  final String? senderId;
  final String? reportId;
  final String? action;
  final String? reason;
  final String? bodyPreview;
  final DateTime? createdAt;

  factory BodyDoubleModerationEvent.fromJson(Map<String, dynamic> json) {
    return BodyDoubleModerationEvent(
      id: json['id'] as String? ?? '',
      sessionId: json['session_id'] as String?,
      senderId: json['sender_id'] as String?,
      reportId: json['report_id'] as String?,
      action: json['action'] as String?,
      reason: json['reason'] as String?,
      bodyPreview: json['body_preview'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }
}

class BodyDoubleAuditEvent {
  const BodyDoubleAuditEvent({
    required this.id,
    this.actorId,
    this.sessionId,
    this.queueId,
    this.eventType,
    this.metadata = const <String, dynamic>{},
    this.createdAt,
  });

  final String id;
  final String? actorId;
  final String? sessionId;
  final String? queueId;
  final String? eventType;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;

  factory BodyDoubleAuditEvent.fromJson(Map<String, dynamic> json) {
    return BodyDoubleAuditEvent(
      id: json['id'] as String? ?? '',
      actorId: json['actor_id'] as String?,
      sessionId: json['session_id'] as String?,
      queueId: json['queue_id'] as String?,
      eventType: json['event_type'] as String?,
      metadata: _mapOrNull(json['metadata']) ?? const <String, dynamic>{},
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }
}

class BodyDoubleUserRestriction {
  const BodyDoubleUserRestriction({
    required this.id,
    required this.user,
    required this.restrictionType,
    required this.status,
    required this.reason,
    this.restrictedBy,
    this.startsAt,
    this.expiresAt,
    this.createdAt,
  });

  final String id;
  final BodyDoubleSafetyUserSummary user;
  final String? restrictedBy;
  final BodyDoubleRestrictionType restrictionType;
  final BodyDoubleRestrictionStatus status;
  final String reason;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  bool get isActive => status == BodyDoubleRestrictionStatus.active;

  factory BodyDoubleUserRestriction.fromJson(Map<String, dynamic> json) {
    return BodyDoubleUserRestriction(
      id: json['id'] as String? ?? '',
      user: BodyDoubleSafetyUserSummary.fromJson(
        json['user_id'] as String?,
        _mapOrNull(json['user_profile']),
      ),
      restrictedBy: json['restricted_by'] as String?,
      restrictionType: BodyDoubleRestrictionTypeLabel.fromValue(
        json['restriction_type'] as String?,
      ),
      status: BodyDoubleRestrictionStatusLabel.fromValue(
        json['status'] as String?,
      ),
      reason: json['reason'] as String? ?? 'Safety concern',
      startsAt: DateTime.tryParse(json['starts_at'] as String? ?? ''),
      expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? ''),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }
}

class BodyDoubleModerationReportDetails {
  const BodyDoubleModerationReportDetails({
    required this.report,
    this.session,
    this.moderationEvents = const <BodyDoubleModerationEvent>[],
    this.auditEvents = const <BodyDoubleAuditEvent>[],
    this.restrictions = const <BodyDoubleUserRestriction>[],
  });

  final BodyDoubleModerationReport report;
  final BodyDoubleModerationSessionSummary? session;
  final List<BodyDoubleModerationEvent> moderationEvents;
  final List<BodyDoubleAuditEvent> auditEvents;
  final List<BodyDoubleUserRestriction> restrictions;
}

class BodyDoubleModerationRetentionCleanupResult {
  const BodyDoubleModerationRetentionCleanupResult({
    required this.allowedPreviewsScrubbed,
    required this.blockedPreviewsScrubbed,
    required this.reportedPreviewsScrubbed,
    required this.auditEventsDeleted,
  });

  final int allowedPreviewsScrubbed;
  final int blockedPreviewsScrubbed;
  final int reportedPreviewsScrubbed;
  final int auditEventsDeleted;

  factory BodyDoubleModerationRetentionCleanupResult.fromJson(
    Map<String, dynamic> json,
  ) {
    return BodyDoubleModerationRetentionCleanupResult(
      allowedPreviewsScrubbed: json['allowed_previews_scrubbed'] as int? ?? 0,
      blockedPreviewsScrubbed: json['blocked_previews_scrubbed'] as int? ?? 0,
      reportedPreviewsScrubbed: json['reported_previews_scrubbed'] as int? ?? 0,
      auditEventsDeleted: json['audit_events_deleted'] as int? ?? 0,
    );
  }
}

abstract class BodyDoubleModerationRepository {
  Future<bool> isCurrentUserModerator();
  Future<List<BodyDoubleModerationReport>> loadModerationReports();
  Future<BodyDoubleModerationReportDetails?> loadModerationReportDetails(
    String reportId,
  );
  Future<List<BodyDoubleModerationEvent>> loadModerationEvents({
    String? sessionId,
    String? reportId,
  });
  Future<List<BodyDoubleAuditEvent>> loadBodyDoubleAuditEvents({
    String? sessionId,
    String? reportId,
  });
  Future<List<BodyDoubleUserRestriction>> loadUserRestrictions({
    String? targetUserId,
    bool? activeOnly,
  });
  Future<void> reviewModerationReport({
    required String reportId,
    required BodyDoubleReportStatus status,
  });
  Future<String?> restrictUser({
    required String targetUserId,
    required BodyDoubleRestrictionType restrictionType,
    required String reason,
    DateTime? expiresAt,
    String? reportId,
  });
  Future<void> revokeRestriction({
    required String restrictionId,
    required String reason,
  });
  Future<BodyDoubleModerationRetentionCleanupResult?>
      runModerationRetentionCleanup();
}

Map<String, dynamic>? _mapOrNull(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}
