import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/voice/voice_settings_model.dart';

class LocalVoiceSettingsStore {
  LocalVoiceSettingsStore({SharedPreferences? preferences})
      : _preferences = preferences;

  static const String _prefix = 'settings.voice.';

  final SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async {
    final injected = _preferences;
    if (injected != null) return injected;
    return SharedPreferences.getInstance();
  }

  Future<VoiceSettingsModel?> load(String userId) async {
    final prefs = await _prefs;
    final raw = prefs.getString('$_prefix$userId');
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      return VoiceSettingsModel.fromJson(
          Map<String, dynamic>.from(decoded as Map));
    } catch (_) {
      return null;
    }
  }

  Future<void> save({
    required String userId,
    required VoiceSettingsModel settings,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(
      '$_prefix$userId',
      jsonEncode(settings.toJson()),
    );
  }
}
