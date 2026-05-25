import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/notifications/app_notification.dart';
import '../../domain/notifications/notification_preferences_model.dart';
import 'notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._client);

  final SupabaseClient? _client;

  @override
  Future<List<AppNotification>> getNotifications(
      {required String userId}) async {
    if (_client == null) return <AppNotification>[];
    try {
      final result = await _client
          .from('app_notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return (result as List<dynamic>)
          .map((json) =>
              AppNotification.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (e) {
      debugPrint('Failed to load notifications: $e');
      return <AppNotification>[];
    }
  }

  @override
  Future<AppNotification?> createNotification({
    required String userId,
    required AppNotificationType type,
    required String title,
    String? body,
    String? route,
    Map<String, dynamic>? routeParams,
    AppNotificationPriority priority = AppNotificationPriority.normal,
    String? sourceType,
    String? sourceId,
    DateTime? scheduledFor,
  }) async {
    final now = DateTime.now().toUtc();
    final payload = <String, dynamic>{
      'user_id': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'route': route,
      'route_params': routeParams ?? <String, dynamic>{},
      'status': AppNotificationStatus.unread.name,
      'priority': priority.name,
      'source_type': sourceType,
      'source_id': sourceId,
      'scheduled_for': scheduledFor?.toIso8601String(),
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    if (_client == null) {
      return AppNotification(
        id: 'local-${now.microsecondsSinceEpoch}',
        userId: userId,
        type: type,
        title: title,
        body: body,
        route: route,
        routeParams: routeParams ?? <String, dynamic>{},
        status: AppNotificationStatus.failed,
        priority: priority,
        sourceType: sourceType,
        sourceId: sourceId,
        scheduledFor: scheduledFor,
        createdAt: now,
        updatedAt: now,
      );
    }

    try {
      final result = await _client
          .from('app_notifications')
          .insert(payload)
          .select()
          .single();
      return AppNotification.fromJson(
        Map<String, dynamic>.from(result as Map),
      );
    } catch (e) {
      debugPrint('Failed to create notification: $e');
      return AppNotification(
        id: 'local-${now.microsecondsSinceEpoch}',
        userId: userId,
        type: type,
        title: title,
        body: body,
        route: route,
        routeParams: routeParams ?? <String, dynamic>{},
        status: AppNotificationStatus.failed,
        priority: priority,
        sourceType: sourceType,
        sourceId: sourceId,
        scheduledFor: scheduledFor,
        createdAt: now,
        updatedAt: now,
      );
    }
  }

  @override
  Future<void> dismissNotification(String notificationId) async {
    if (_client == null) return;
    try {
      await _client.from('app_notifications').update({
        'status': AppNotificationStatus.dismissed.name,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', notificationId);
    } catch (e) {
      debugPrint('Failed to dismiss notification: $e');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    if (_client == null) return;
    try {
      await _client.from('app_notifications').update({
        'status': AppNotificationStatus.read.name,
        'read_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', notificationId);
    } catch (e) {
      debugPrint('Failed to mark notification read: $e');
    }
  }

  @override
  Future<NotificationPreferencesModel?> getPreferences(String userId) async {
    if (_client == null) {
      return NotificationPreferencesModel.defaults(userId);
    }

    try {
      final result = await _client
          .from('notification_preferences')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (result == null) {
        return NotificationPreferencesModel.defaults(userId);
      }
      return NotificationPreferencesModel.fromJson(
        Map<String, dynamic>.from(result as Map),
      );
    } catch (e) {
      debugPrint('Failed to load notification preferences: $e');
      return NotificationPreferencesModel.defaults(userId);
    }
  }

  @override
  Future<NotificationPreferencesModel?> savePreferences(
      NotificationPreferencesModel preferences) async {
    if (_client == null) {
      return preferences;
    }

    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final result = await _client
          .from('notification_preferences')
          .upsert(
            <String, dynamic>{
              'user_id': preferences.userId,
              'enabled': preferences.enabled,
              'quiet_hours_start': preferences.quietHoursStart,
              'quiet_hours_end': preferences.quietHoursEnd,
              'allow_task_reminders': preferences.allowTaskReminders,
              'allow_caregiver_notifications':
                  preferences.allowCaregiverNotifications,
              'allow_body_double_notifications':
                  preferences.allowBodyDoubleNotifications,
              'allow_side_quests': preferences.allowSideQuests,
              'allow_moderation_updates': preferences.allowModerationUpdates,
              'updated_at': now,
            },
            onConflict: 'user_id',
          )
          .select()
          .single();

      return NotificationPreferencesModel.fromJson(
        Map<String, dynamic>.from(result as Map),
      );
    } catch (e) {
      debugPrint('Failed to save notification preferences: $e');
      return preferences;
    }
  }
}
