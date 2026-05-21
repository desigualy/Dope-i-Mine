class NotificationPreferencesModel {
  const NotificationPreferencesModel({
    required this.userId,
    this.enabled = true,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '07:00',
    this.allowTaskReminders = true,
    this.allowCaregiverNotifications = true,
    this.allowBodyDoubleNotifications = true,
    this.allowSideQuests = true,
    this.allowModerationUpdates = true,
    required this.createdAt,
    required this.updatedAt,
  });

  static NotificationPreferencesModel defaults(String userId) {
    final now = DateTime.now();
    return NotificationPreferencesModel(
      userId: userId,
      enabled: true,
      quietHoursStart: '22:00',
      quietHoursEnd: '07:00',
      allowTaskReminders: true,
      allowCaregiverNotifications: true,
      allowBodyDoubleNotifications: true,
      allowSideQuests: true,
      allowModerationUpdates: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  final String userId;
  final bool enabled;
  final String quietHoursStart;
  final String quietHoursEnd;
  final bool allowTaskReminders;
  final bool allowCaregiverNotifications;
  final bool allowBodyDoubleNotifications;
  final bool allowSideQuests;
  final bool allowModerationUpdates;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationPreferencesModel copyWith({
    String? userId,
    bool? enabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool? allowTaskReminders,
    bool? allowCaregiverNotifications,
    bool? allowBodyDoubleNotifications,
    bool? allowSideQuests,
    bool? allowModerationUpdates,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationPreferencesModel(
      userId: userId ?? this.userId,
      enabled: enabled ?? this.enabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      allowTaskReminders: allowTaskReminders ?? this.allowTaskReminders,
      allowCaregiverNotifications:
          allowCaregiverNotifications ?? this.allowCaregiverNotifications,
      allowBodyDoubleNotifications:
          allowBodyDoubleNotifications ?? this.allowBodyDoubleNotifications,
      allowSideQuests: allowSideQuests ?? this.allowSideQuests,
      allowModerationUpdates:
          allowModerationUpdates ?? this.allowModerationUpdates,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesModel(
      userId: json['user_id'] as String,
      enabled: json['enabled'] as bool? ?? true,
      quietHoursStart: json['quiet_hours_start'] as String? ?? '22:00',
      quietHoursEnd: json['quiet_hours_end'] as String? ?? '07:00',
      allowTaskReminders: json['allow_task_reminders'] as bool? ?? true,
      allowCaregiverNotifications:
          json['allow_caregiver_notifications'] as bool? ?? true,
      allowBodyDoubleNotifications:
          json['allow_body_double_notifications'] as bool? ?? true,
      allowSideQuests: json['allow_side_quests'] as bool? ?? true,
      allowModerationUpdates:
          json['allow_moderation_updates'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'user_id': userId,
      'enabled': enabled,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
      'allow_task_reminders': allowTaskReminders,
      'allow_caregiver_notifications': allowCaregiverNotifications,
      'allow_body_double_notifications': allowBodyDoubleNotifications,
      'allow_side_quests': allowSideQuests,
      'allow_moderation_updates': allowModerationUpdates,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
