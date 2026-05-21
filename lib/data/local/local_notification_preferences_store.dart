import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/notifications/notification_preferences_model.dart';

class LocalNotificationPreferencesStore {
  LocalNotificationPreferencesStore({SharedPreferences? preferences})
      : _preferences = preferences;

  static const String _prefix = 'settings.notification.';

  final SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async {
    final injected = _preferences;
    if (injected != null) return injected;
    return SharedPreferences.getInstance();
  }

  Future<NotificationPreferencesModel?> load(String userId) async {
    final prefs = await _prefs;
    final raw = prefs.getString('$_prefix$userId');
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      return NotificationPreferencesModel.fromJson(
          Map<String, dynamic>.from(decoded as Map));
    } catch (_) {
      return null;
    }
  }

  Future<void> save(NotificationPreferencesModel preferences) async {
    final prefs = await _prefs;
    await prefs.setString(
      '$_prefix${preferences.userId}',
      jsonEncode(preferences.toJson()),
    );
  }
}
