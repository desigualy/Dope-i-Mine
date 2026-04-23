import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';
import '../models/cached_task_session_model.dart';

class LocalTaskSessionCacheService {
  Future<void> save(CachedTaskSessionModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.activeTaskSession, jsonEncode(model.toJson()));
  }

  Future<CachedTaskSessionModel?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(StorageKeys.activeTaskSession);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return CachedTaskSessionModel.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.activeTaskSession);
  }
}
