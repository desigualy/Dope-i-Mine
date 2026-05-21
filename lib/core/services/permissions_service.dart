import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PermissionsService {
  PermissionsService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  Future<bool> requestMicrophone() async {
    // Replace with permission_handler or equivalent if you want runtime prompts
    // centralized here later. For now, platform manifests/plists must be correct.
    return true;
  }

  Future<bool> requestNotifications() async {
    try {
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
    } catch (_) {
      return false;
    }
  }
}
