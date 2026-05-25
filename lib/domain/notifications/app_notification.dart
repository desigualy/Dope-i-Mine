import 'dart:convert';

enum AppNotificationType {
  caregiverTaskAssigned,
  caregiverRoutineAssigned,
  caregiverNudge,
  bodyDoubleInvite,
  bodyDoubleInviteAccepted,
  bodyDoubleMatch,
  sideQuestSuggested,
  overwhelmFollowUp,
  moderationUpdate,
  taskReminder,
  routineReminder,
  other,
}

extension AppNotificationTypeX on AppNotificationType {
  String get name {
    return toString().split('.').last;
  }

  static AppNotificationType fromJson(String value) {
    return AppNotificationType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => AppNotificationType.other,
    );
  }
}

enum AppNotificationStatus {
  unread,
  read,
  dismissed,
  delivered,
  failed,
  scheduled,
}

extension AppNotificationStatusX on AppNotificationStatus {
  String get name {
    return toString().split('.').last;
  }

  static AppNotificationStatus fromJson(String value) {
    return AppNotificationStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => AppNotificationStatus.unread,
    );
  }
}

enum AppNotificationPriority {
  low,
  normal,
  high,
}

extension AppNotificationPriorityX on AppNotificationPriority {
  String get name {
    return toString().split('.').last;
  }

  static AppNotificationPriority fromJson(String value) {
    return AppNotificationPriority.values.firstWhere(
      (priority) => priority.name == value,
      orElse: () => AppNotificationPriority.normal,
    );
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.body,
    this.route,
    this.routeParams = const {},
    this.status = AppNotificationStatus.unread,
    this.priority = AppNotificationPriority.normal,
    this.sourceType,
    this.sourceId,
    this.scheduledFor,
    this.deliveredAt,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final AppNotificationType type;
  final String title;
  final String? body;
  final String? route;
  final Map<String, dynamic> routeParams;
  final AppNotificationStatus status;
  final AppNotificationPriority priority;
  final String? sourceType;
  final String? sourceId;
  final DateTime? scheduledFor;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppNotification copyWith({
    String? id,
    String? userId,
    AppNotificationType? type,
    String? title,
    String? body,
    String? route,
    Map<String, dynamic>? routeParams,
    AppNotificationStatus? status,
    AppNotificationPriority? priority,
    String? sourceType,
    String? sourceId,
    DateTime? scheduledFor,
    DateTime? deliveredAt,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      route: route ?? this.route,
      routeParams: routeParams ?? this.routeParams,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final routeParams = json['route_params'];
    Map<String, dynamic> parsedParams;
    if (routeParams is String && routeParams.isNotEmpty) {
      parsedParams = Map<String, dynamic>.from(
          jsonDecode(routeParams) as Map<String, dynamic>);
    } else if (routeParams is Map) {
      parsedParams = Map<String, dynamic>.from(routeParams);
    } else {
      parsedParams = <String, dynamic>{};
    }

    return AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: AppNotificationTypeX.fromJson(json['type'] as String? ?? 'other'),
      title: json['title'] as String? ?? '',
      body: json['body'] as String?,
      route: json['route'] as String?,
      routeParams: parsedParams,
      status: AppNotificationStatusX.fromJson(
          json['status'] as String? ?? 'unread'),
      priority: AppNotificationPriorityX.fromJson(
          json['priority'] as String? ?? 'normal'),
      sourceType: json['source_type'] as String?,
      sourceId: json['source_id'] as String?,
      scheduledFor: json['scheduled_for'] == null
          ? null
          : DateTime.parse(json['scheduled_for'] as String),
      deliveredAt: json['delivered_at'] == null
          ? null
          : DateTime.parse(json['delivered_at'] as String),
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'route': route,
      'route_params': routeParams,
      'status': status.name,
      'priority': priority.name,
      'source_type': sourceType,
      'source_id': sourceId,
      'scheduled_for': scheduledFor?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    }..removeWhere((key, value) => value == null);
  }
}
