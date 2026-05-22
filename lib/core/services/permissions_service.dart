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
    // Platform notification permission semantics differ across platforms
    // and the flutter_local_notifications API surface changes between
    // plugin versions. For test and onboarding flows we'll optimistically
    // assume notifications are available when the plugin is present.
    try {
      return true;
    } catch (_) {
      return false;
    }
  }
}
