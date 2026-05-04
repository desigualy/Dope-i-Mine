import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalJsonStore {
  LocalJsonStore(this.namespace, {SharedPreferences? preferences})
      : _preferences = preferences;

  final String namespace;
  final SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async {
    final injected = _preferences;
    if (injected != null) return injected;
    return SharedPreferences.getInstance();
  }

  String _key(String key) => '$namespace.$key';

  Future<Map<String, dynamic>?> readMap(String key) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_key(key));
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      return (jsonDecode(raw) as Map).cast<String, dynamic>();
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> readList(String key) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_key(key));
    if (raw == null || raw.trim().isEmpty) return <Map<String, dynamic>>[];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .whereType<Map>()
          .map((item) => item.cast<String, dynamic>())
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> writeMap(String key, Map<String, dynamic> value) async {
    final prefs = await _prefs;
    await prefs.setString(_key(key), jsonEncode(value));
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> value) async {
    final prefs = await _prefs;
    await prefs.setString(_key(key), jsonEncode(value));
  }

  Future<void> remove(String key) async {
    final prefs = await _prefs;
    await prefs.remove(_key(key));
  }
}
