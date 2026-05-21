import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../constants/reminder_constants.dart';
import '../../app/router.dart';

class ReminderService {
  ReminderService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void> Function(String? payload)? _onNotificationTap;

  Future<void> initialize({
    Future<void> Function(String? payload)? onNotificationTap,
  }) async {
    _onNotificationTap = onNotificationTap;
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _handleNotificationResponse,
    );
  }

  Future<bool> requestNotifications() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<DarwinFlutterLocalNotificationsPlugin>();

    final androidGranted = await android?.requestPermission() ?? true;
    final iosGranted = await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;

    return androidGranted && iosGranted;
  }

  Future<void> showInstant({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        ReminderConstants.channelId,
        ReminderConstants.channelName,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(id, title, body, details, payload: payload);
  }

  Future<void> scheduleOneTime({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          ReminderConstants.channelId,
          ReminderConstants.channelName,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          ReminderConstants.channelId,
          ReminderConstants.channelName,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (_onNotificationTap != null) {
      _onNotificationTap?.call(payload);
      return;
    }
    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final route = data['route'] as String?;
      final params = data['params'] as Map<String, dynamic>?;
      if (route != null) {
        final uri = Uri(
          path: route,
          queryParameters:
              params?.map((key, value) => MapEntry(key, value.toString())),
        );
        appRouter.go(uri.toString());
      }
    } catch (_) {
      // Ignore invalid payloads.
    }
  }
}
