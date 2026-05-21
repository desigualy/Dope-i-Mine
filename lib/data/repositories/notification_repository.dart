import '../../domain/notifications/app_notification.dart';
import '../../domain/notifications/notification_preferences_model.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications({required String userId});
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
  });
  Future<void> markAsRead(String notificationId);
  Future<void> dismissNotification(String notificationId);
  Future<NotificationPreferencesModel?> getPreferences(String userId);
  Future<NotificationPreferencesModel?> savePreferences(
      NotificationPreferencesModel preferences);
}
