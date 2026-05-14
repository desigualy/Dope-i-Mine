/// The type of presence alongside the user during a body double session.
enum BodyDoubleMode { dopei, friend, random }

/// Mirrors the server-side body_double_sessions.status contract.
///
/// Random sessions must remain unreleasable until the safety-critical tables,
/// age gates, block/report flows, audit logs, and RLS policies are present.
enum BodyDoubleStatus {
  waiting,
  active,
  paused,
  completed,
  cancelled,
  reported
}

enum BodyDoubleCommunicationMode { quiet, presetSignals, textOnly, voice }

enum BodyDoublePrivacyLevel { private, titleOnly, progressOnly, fullSteps }

enum BodyDoubleAgeBand { child, preTeen, teen, adult }

enum BodyDoubleParticipantStatus {
  invited,
  accepted,
  declined,
  active,
  left,
  removed
}

enum BodyDoubleInviteStatus { pending, accepted, declined, expired, cancelled }

enum BodyDoubleSignalType {
  started,
  stillHere,
  stepDone,
  breakStart,
  breakEnd,
  wrappingUp,
  thanks,
  left,
}

enum BodyDoubleSessionType {
  quickStart,
  focusSprint,
  choreBuddy,
  calmSupport,
  overwhelmMode,
}

extension BodyDoubleSessionTypeLabel on BodyDoubleSessionType {
  String get label {
    switch (this) {
      case BodyDoubleSessionType.quickStart:
        return 'Quick Start';
      case BodyDoubleSessionType.focusSprint:
        return 'Focus Sprint';
      case BodyDoubleSessionType.choreBuddy:
        return 'Chore Buddy';
      case BodyDoubleSessionType.calmSupport:
        return 'Calm Support';
      case BodyDoubleSessionType.overwhelmMode:
        return 'Overwhelm Mode';
    }
  }

  String get description {
    switch (this) {
      case BodyDoubleSessionType.quickStart:
        return 'Five minutes of gentle activation.';
      case BodyDoubleSessionType.focusSprint:
        return 'A 25-minute calm focus sprint.';
      case BodyDoubleSessionType.choreBuddy:
        return 'Step-by-step support for practical tasks.';
      case BodyDoubleSessionType.calmSupport:
        return 'Open-ended, no-pressure presence.';
      case BodyDoubleSessionType.overwhelmMode:
        return 'Find the smallest possible next step.';
    }
  }

  int? get defaultMinutes {
    switch (this) {
      case BodyDoubleSessionType.quickStart:
        return 5;
      case BodyDoubleSessionType.focusSprint:
        return 25;
      case BodyDoubleSessionType.choreBuddy:
        return 15;
      case BodyDoubleSessionType.calmSupport:
      case BodyDoubleSessionType.overwhelmMode:
        return null;
    }
  }

  int get defaultCheckInMinutes {
    switch (this) {
      case BodyDoubleSessionType.quickStart:
        return 2;
      case BodyDoubleSessionType.focusSprint:
        return 5;
      case BodyDoubleSessionType.choreBuddy:
        return 4;
      case BodyDoubleSessionType.calmSupport:
        return 10;
      case BodyDoubleSessionType.overwhelmMode:
        return 3;
    }
  }
}

class BodyDoubleSession {
  const BodyDoubleSession({
    required this.id,
    required this.mode,
    required this.status,
    required this.sessionType,
    required this.startedAt,
    this.taskId,
    this.taskTitle,
    this.goal,
    this.endedAt,
    this.sessionLengthMinutes,
    this.communicationMode = BodyDoubleCommunicationMode.quiet,
    this.privacyLevel = BodyDoublePrivacyLevel.private,
    this.checkInIntervalMinutes = 5,
    this.quietMode = true,
    this.textOnlyMode = false,
    this.voiceEnabled = false,
    this.stepsCompleted = 0,
    this.overwhelmEvents = 0,
    this.summary,
  });

  final String id;
  final BodyDoubleMode mode;
  final BodyDoubleStatus status;
  final BodyDoubleSessionType sessionType;
  final String? taskId;
  final String? taskTitle;
  final String? goal;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? sessionLengthMinutes;
  final BodyDoubleCommunicationMode communicationMode;
  final BodyDoublePrivacyLevel privacyLevel;
  final int checkInIntervalMinutes;
  final bool quietMode;
  final bool textOnlyMode;
  final bool voiceEnabled;
  final int stepsCompleted;
  final int overwhelmEvents;
  final String? summary;

  int get durationSeconds {
    final end = endedAt ?? DateTime.now();
    return end.difference(startedAt).inSeconds.clamp(0, 1 << 31);
  }

  BodyDoubleSession copyWith({
    BodyDoubleStatus? status,
    DateTime? endedAt,
    int? stepsCompleted,
    int? overwhelmEvents,
    String? summary,
    BodyDoubleCommunicationMode? communicationMode,
    BodyDoublePrivacyLevel? privacyLevel,
  }) {
    return BodyDoubleSession(
      id: id,
      mode: mode,
      status: status ?? this.status,
      sessionType: sessionType,
      taskId: taskId,
      taskTitle: taskTitle,
      goal: goal,
      startedAt: startedAt,
      endedAt: endedAt ?? this.endedAt,
      sessionLengthMinutes: sessionLengthMinutes,
      communicationMode: communicationMode ?? this.communicationMode,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      checkInIntervalMinutes: checkInIntervalMinutes,
      quietMode: quietMode,
      textOnlyMode: textOnlyMode,
      voiceEnabled: voiceEnabled,
      stepsCompleted: stepsCompleted ?? this.stepsCompleted,
      overwhelmEvents: overwhelmEvents ?? this.overwhelmEvents,
      summary: summary ?? this.summary,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'mode': mode.name,
      'status': status.name,
      'sessionType': sessionType.name,
      'taskId': taskId,
      'taskTitle': taskTitle,
      'goal': goal,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'sessionLengthMinutes': sessionLengthMinutes,
      'communicationMode': communicationMode.name,
      'privacyLevel': privacyLevel.name,
      'checkInIntervalMinutes': checkInIntervalMinutes,
      'quietMode': quietMode,
      'textOnlyMode': textOnlyMode,
      'voiceEnabled': voiceEnabled,
      'stepsCompleted': stepsCompleted,
      'overwhelmEvents': overwhelmEvents,
      'summary': summary,
    };
  }

  static BodyDoubleSession fromJson(Map<String, dynamic> json) {
    return BodyDoubleSession(
      id: json['id'] as String? ?? '',
      mode: _enumByName(
          json['mode'], BodyDoubleMode.values, BodyDoubleMode.dopei),
      status: _enumByName(
        json['status'],
        BodyDoubleStatus.values,
        BodyDoubleStatus.waiting,
      ),
      sessionType: _enumByName(
        json['sessionType'],
        BodyDoubleSessionType.values,
        BodyDoubleSessionType.quickStart,
      ),
      taskId: json['taskId'] as String?,
      taskTitle: json['taskTitle'] as String?,
      goal: json['goal'] as String?,
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ??
          DateTime.now(),
      endedAt: DateTime.tryParse(json['endedAt'] as String? ?? ''),
      sessionLengthMinutes: json['sessionLengthMinutes'] as int?,
      communicationMode: _enumByName(
        json['communicationMode'] ?? json['communication_mode'],
        BodyDoubleCommunicationMode.values,
        BodyDoubleCommunicationMode.quiet,
      ),
      privacyLevel: _enumByName(
        json['privacyLevel'] ?? json['privacy_level'],
        BodyDoublePrivacyLevel.values,
        BodyDoublePrivacyLevel.private,
      ),
      checkInIntervalMinutes: json['checkInIntervalMinutes'] as int? ?? 5,
      quietMode: json['quietMode'] != false,
      textOnlyMode: json['textOnlyMode'] == true,
      voiceEnabled: json['voiceEnabled'] == true,
      stepsCompleted: json['stepsCompleted'] as int? ?? 0,
      overwhelmEvents: json['overwhelmEvents'] as int? ?? 0,
      summary: json['summary'] as String?,
    );
  }
}

class BodyDoubleParticipant {
  const BodyDoubleParticipant({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.role,
    required this.status,
    this.joinedAt,
    this.leftAt,
    this.ageBandSnapshot,
    this.displayNameSnapshot,
    this.anonymousLabel,
  });

  final String id;
  final String sessionId;
  final String userId;
  final String role;
  final BodyDoubleParticipantStatus status;
  final DateTime? joinedAt;
  final DateTime? leftAt;
  final BodyDoubleAgeBand? ageBandSnapshot;
  final String? displayNameSnapshot;
  final String? anonymousLabel;

  BodyDoubleParticipant copyWith({
    BodyDoubleParticipantStatus? status,
    DateTime? joinedAt,
    DateTime? leftAt,
  }) {
    return BodyDoubleParticipant(
      id: id,
      sessionId: sessionId,
      userId: userId,
      role: role,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      leftAt: leftAt ?? this.leftAt,
      ageBandSnapshot: ageBandSnapshot,
      displayNameSnapshot: displayNameSnapshot,
      anonymousLabel: anonymousLabel,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'sessionId': sessionId,
      'userId': userId,
      'role': role,
      'status': status.name,
      'joinedAt': joinedAt?.toIso8601String(),
      'leftAt': leftAt?.toIso8601String(),
      'ageBandSnapshot': ageBandSnapshot?.name,
      'displayNameSnapshot': displayNameSnapshot,
      'anonymousLabel': anonymousLabel,
    };
  }

  static BodyDoubleParticipant fromJson(Map<String, dynamic> json) {
    return BodyDoubleParticipant(
      id: json['id'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      role: json['role'] as String? ?? 'participant',
      status: _enumByName(
        json['status'],
        BodyDoubleParticipantStatus.values,
        BodyDoubleParticipantStatus.invited,
      ),
      joinedAt: DateTime.tryParse(json['joinedAt'] as String? ?? ''),
      leftAt: DateTime.tryParse(json['leftAt'] as String? ?? ''),
      ageBandSnapshot: _enumByName(
        json['ageBandSnapshot'],
        BodyDoubleAgeBand.values,
        BodyDoubleAgeBand.adult,
      ),
      displayNameSnapshot: json['displayNameSnapshot'] as String?,
      anonymousLabel: json['anonymousLabel'] as String?,
    );
  }
}

class BodyDoubleInvite {
  const BodyDoubleInvite({
    required this.id,
    required this.sessionId,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
    this.respondedAt,
  });

  final String id;
  final String sessionId;
  final String senderId;
  final String receiverId;
  final BodyDoubleInviteStatus status;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime? respondedAt;

  BodyDoubleInvite copyWith({
    BodyDoubleInviteStatus? status,
    DateTime? respondedAt,
  }) {
    return BodyDoubleInvite(
      id: id,
      sessionId: sessionId,
      senderId: senderId,
      receiverId: receiverId,
      status: status ?? this.status,
      expiresAt: expiresAt,
      createdAt: createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'sessionId': sessionId,
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status.name,
      'expiresAt': expiresAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  static BodyDoubleInvite fromJson(Map<String, dynamic> json) {
    return BodyDoubleInvite(
      id: json['id'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      receiverId: json['receiverId'] as String? ?? '',
      status: _enumByName(
        json['status'],
        BodyDoubleInviteStatus.values,
        BodyDoubleInviteStatus.pending,
      ),
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? '') ??
          DateTime.now(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      respondedAt: DateTime.tryParse(json['respondedAt'] as String? ?? ''),
    );
  }
}

class BodyDoubleQueueEntry {
  const BodyDoubleQueueEntry({
    required this.id,
    required this.userId,
    required this.ageBand,
    required this.taskCategory,
    required this.sessionLengthMinutes,
    required this.communicationMode,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.guardianApproved = false,
    this.randomMatchingEnabled = false,
  });

  final String id;
  final String userId;
  final BodyDoubleAgeBand ageBand;
  final String taskCategory;
  final int sessionLengthMinutes;
  final BodyDoubleCommunicationMode communicationMode;
  final BodyDoubleStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool guardianApproved;
  final bool randomMatchingEnabled;

  bool get isMinor => ageBand != BodyDoubleAgeBand.adult;

  bool get canEnterRandomQueue {
    if (!randomMatchingEnabled) return false;
    if (!isMinor) return true;
    return guardianApproved &&
        communicationMode != BodyDoubleCommunicationMode.textOnly &&
        communicationMode != BodyDoubleCommunicationMode.voice;
  }

  bool canMatchWith(BodyDoubleQueueEntry other) {
    if (!canEnterRandomQueue || !other.canEnterRandomQueue) return false;
    if (ageBand != other.ageBand) return false;
    if (isMinor && other.ageBand == BodyDoubleAgeBand.adult) return false;
    if (other.isMinor && ageBand == BodyDoubleAgeBand.adult) return false;
    return communicationMode == other.communicationMode;
  }
}

class RandomBodyDoubleEligibility {
  const RandomBodyDoubleEligibility({
    required this.userId,
    required this.ageBand,
    required this.randomMatchingEnabled,
    required this.guardianApproved,
    required this.presetSignalsAllowed,
    required this.quietModeAllowed,
    required this.textAllowed,
    required this.voiceAllowed,
    required this.canEnterRandomQueue,
  });

  final String userId;
  final BodyDoubleAgeBand ageBand;
  final bool randomMatchingEnabled;
  final bool guardianApproved;
  final bool presetSignalsAllowed;
  final bool quietModeAllowed;
  final bool textAllowed;
  final bool voiceAllowed;
  final bool canEnterRandomQueue;

  bool allowsCommunicationMode(BodyDoubleCommunicationMode mode) {
    switch (mode) {
      case BodyDoubleCommunicationMode.quiet:
        return quietModeAllowed;
      case BodyDoubleCommunicationMode.presetSignals:
        return presetSignalsAllowed;
      case BodyDoubleCommunicationMode.textOnly:
        return textAllowed && ageBand == BodyDoubleAgeBand.adult;
      case BodyDoubleCommunicationMode.voice:
        return voiceAllowed && ageBand == BodyDoubleAgeBand.adult;
    }
  }

  static RandomBodyDoubleEligibility fromJson(Map<String, dynamic> json) {
    return RandomBodyDoubleEligibility(
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      ageBand: _enumByName(
        _normalizeAgeBandName(json['age_band'] ?? json['ageBand']),
        BodyDoubleAgeBand.values,
        BodyDoubleAgeBand.adult,
      ),
      randomMatchingEnabled: json['random_matching_enabled'] as bool? ??
          json['randomMatchingEnabled'] as bool? ??
          false,
      guardianApproved: json['guardian_approved'] as bool? ??
          json['guardianApproved'] as bool? ??
          false,
      presetSignalsAllowed: json['preset_signals_allowed'] as bool? ??
          json['presetSignalsAllowed'] as bool? ??
          true,
      quietModeAllowed: json['quiet_mode_allowed'] as bool? ??
          json['quietModeAllowed'] as bool? ??
          true,
      textAllowed: json['text_allowed'] as bool? ??
          json['textAllowed'] as bool? ??
          false,
      voiceAllowed: json['voice_allowed'] as bool? ??
          json['voiceAllowed'] as bool? ??
          false,
      canEnterRandomQueue: json['can_enter_random_queue'] as bool? ??
          json['canEnterRandomQueue'] as bool? ??
          false,
    );
  }
}

enum RandomBodyDoubleTextSafetyStatus {
  allowed,
  empty,
  tooLong,
  containsLink,
  containsContactInfo,
  containsLocationRequest,
  containsUnsafeContent,
}

class RandomBodyDoubleTextSafetyResult {
  const RandomBodyDoubleTextSafetyResult({
    required this.status,
    required this.sanitizedText,
  });

  final RandomBodyDoubleTextSafetyStatus status;
  final String sanitizedText;

  bool get isAllowed => status == RandomBodyDoubleTextSafetyStatus.allowed;

  String get userMessage {
    switch (status) {
      case RandomBodyDoubleTextSafetyStatus.allowed:
        return 'Message sent.';
      case RandomBodyDoubleTextSafetyStatus.empty:
        return 'Type a short body-double message first.';
      case RandomBodyDoubleTextSafetyStatus.tooLong:
        return 'Keep random-session text short and simple.';
      case RandomBodyDoubleTextSafetyStatus.containsLink:
        return 'Links are not allowed in random body double sessions.';
      case RandomBodyDoubleTextSafetyStatus.containsContactInfo:
        return 'Contact details and social handles are not allowed here.';
      case RandomBodyDoubleTextSafetyStatus.containsLocationRequest:
        return 'Location sharing or location requests are not allowed here.';
      case RandomBodyDoubleTextSafetyStatus.containsUnsafeContent:
        return 'That message is not allowed in random body double sessions.';
    }
  }
}

class RandomBodyDoubleTextSafety {
  const RandomBodyDoubleTextSafety._();

  static RandomBodyDoubleTextSafetyResult check(String input) {
    final sanitized = input.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (sanitized.isEmpty) {
      return const RandomBodyDoubleTextSafetyResult(
        status: RandomBodyDoubleTextSafetyStatus.empty,
        sanitizedText: '',
      );
    }
    if (sanitized.length > 160) {
      return RandomBodyDoubleTextSafetyResult(
        status: RandomBodyDoubleTextSafetyStatus.tooLong,
        sanitizedText: sanitized,
      );
    }
    final lower = sanitized.toLowerCase();
    if (RegExp(
            r'([\w.+-]+@[\w.-]+\.[a-z]{2,}|\+?\d[\d\s().-]{7,}\d|@[a-z0-9_.-]{3,})')
        .hasMatch(lower)) {
      return RandomBodyDoubleTextSafetyResult(
        status: RandomBodyDoubleTextSafetyStatus.containsContactInfo,
        sanitizedText: sanitized,
      );
    }
    if (RegExp(r'(https?://|www\.|\.com\b|\.net\b|\.org\b|\.io\b)')
        .hasMatch(lower)) {
      return RandomBodyDoubleTextSafetyResult(
        status: RandomBodyDoubleTextSafetyStatus.containsLink,
        sanitizedText: sanitized,
      );
    }
    if (RegExp(
            r'\b(where do you live|your address|my address|meet me|location|postcode|zip code)\b')
        .hasMatch(lower)) {
      return RandomBodyDoubleTextSafetyResult(
        status: RandomBodyDoubleTextSafetyStatus.containsLocationRequest,
        sanitizedText: sanitized,
      );
    }
    if (RegExp(
            r'\b(sex|sexual|nude|kill yourself|kys|suicide|self[- ]?harm|fuck|shit|bitch|cunt)\b')
        .hasMatch(lower)) {
      return RandomBodyDoubleTextSafetyResult(
        status: RandomBodyDoubleTextSafetyStatus.containsUnsafeContent,
        sanitizedText: sanitized,
      );
    }
    return RandomBodyDoubleTextSafetyResult(
      status: RandomBodyDoubleTextSafetyStatus.allowed,
      sanitizedText: sanitized,
    );
  }
}

class RandomBodyDoubleSafetySettings {
  const RandomBodyDoubleSafetySettings({
    required this.userId,
    this.randomMatchingEnabled = false,
    this.guardianRandomApproved = false,
    this.presetSignalsAllowed = true,
    this.quietModeAllowed = true,
    this.textAllowed = false,
    this.voiceAllowed = false,
  });

  final String userId;
  final bool randomMatchingEnabled;
  final bool guardianRandomApproved;
  final bool presetSignalsAllowed;
  final bool quietModeAllowed;
  final bool textAllowed;
  final bool voiceAllowed;

  static RandomBodyDoubleSafetySettings fromJson(Map<String, dynamic> json) {
    return RandomBodyDoubleSafetySettings(
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      randomMatchingEnabled: json['random_matching_enabled'] as bool? ?? false,
      guardianRandomApproved:
          json['guardian_random_approved'] as bool? ?? false,
      presetSignalsAllowed: json['preset_signals_allowed'] as bool? ?? true,
      quietModeAllowed: json['quiet_mode_allowed'] as bool? ?? true,
      textAllowed: json['text_allowed'] as bool? ?? false,
      voiceAllowed: json['voice_allowed'] as bool? ?? false,
    );
  }
}

class BodyDoubleSignal {
  const BodyDoubleSignal({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.signalType,
    required this.createdAt,
  });

  final String id;
  final String sessionId;
  final String userId;
  final BodyDoubleSignalType signalType;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'sessionId': sessionId,
      'userId': userId,
      'signalType': signalType.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static BodyDoubleSignal fromJson(Map<String, dynamic> json) {
    return BodyDoubleSignal(
      id: json['id'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      signalType: _enumByName(
        json['signalType'],
        BodyDoubleSignalType.values,
        BodyDoubleSignalType.stillHere,
      ),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class BodyDoubleMessage {
  const BodyDoubleMessage({
    required this.id,
    required this.sessionId,
    required this.senderId,
    required this.messageType,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String sessionId;
  final String senderId;
  final String messageType;
  final String body;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'sessionId': sessionId,
      'senderId': senderId,
      'messageType': messageType,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static BodyDoubleMessage fromJson(Map<String, dynamic> json) {
    return BodyDoubleMessage(
      id: json['id'] as String? ?? '',
      sessionId: json['sessionId'] ?? json['session_id'] as String? ?? '',
      senderId: json['senderId'] ?? json['sender_id'] as String? ?? '',
      messageType:
          json['messageType'] ?? json['message_type'] as String? ?? 'preset',
      body: json['body'] as String? ?? '',
      createdAt: DateTime.tryParse(
              json['createdAt'] ?? json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class BodyDoubleReport {
  const BodyDoubleReport({
    required this.id,
    required this.sessionId,
    required this.reporterId,
    required this.reportedUserId,
    required this.reason,
    required this.createdAt,
    this.details,
    this.status = 'open',
  });

  final String id;
  final String sessionId;
  final String reporterId;
  final String reportedUserId;
  final String reason;
  final String? details;
  final DateTime createdAt;
  final String status;
}

T _enumByName<T extends Enum>(Object? value, List<T> values, T fallback) {
  if (value is String) {
    for (final item in values) {
      if (item.name == value) return item;
    }
  }
  return fallback;
}

String? _normalizeAgeBandName(Object? value) {
  if (value == 'preteen') return 'preTeen';
  return value as String?;
}
