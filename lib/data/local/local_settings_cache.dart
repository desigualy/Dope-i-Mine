import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/profile/sensory_settings_model.dart';

class LocalSettingsCache {
  const LocalSettingsCache(this._prefs);

  static const String _sensoryPrefix = 'settings.sensory.';

  final SharedPreferences _prefs;

  Future<SensorySettingsModel?> loadSensorySettings(String userId) async {
    final raw = _prefs.getString('$_sensoryPrefix$userId');
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return _sensoryFromJson(decoded);
      }
      if (decoded is Map) {
        return _sensoryFromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  Future<void> saveSensorySettings(
    String userId,
    SensorySettingsModel settings,
  ) async {
    await _prefs.setString(
      '$_sensoryPrefix$userId',
      jsonEncode(<String, dynamic>{
        'reducedAnimation': settings.reducedAnimation,
        'largeText': settings.largeText,
        'softColors': settings.softColors,
        'soundEnabled': settings.soundEnabled,
        'praiseLevel': settings.praiseLevel,
        'iconMode': settings.iconMode,
        'reduceSurprises': settings.reduceSurprises,
      }),
    );
  }

  SensorySettingsModel _sensoryFromJson(Map<String, dynamic> json) {
    return SensorySettingsModel(
      reducedAnimation: json['reducedAnimation'] == true,
      largeText: json['largeText'] == true,
      softColors:
          json['softColors'] is bool ? json['softColors'] as bool : true,
      soundEnabled:
          json['soundEnabled'] is bool ? json['soundEnabled'] as bool : true,
      praiseLevel: json['praiseLevel'] is String
          ? json['praiseLevel'] as String
          : 'medium',
      iconMode: json['iconMode'] == true,
      reduceSurprises: json['reduceSurprises'] is bool
          ? json['reduceSurprises'] as bool
          : true,
    );
  }
}
