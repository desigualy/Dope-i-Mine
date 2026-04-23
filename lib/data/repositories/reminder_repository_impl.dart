import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/reminders/reminder_model.dart';

class ReminderRepositoryImpl {
  static const String _key = 'saved_reminders';

  Future<List<ReminderModel>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return <ReminderModel>[];

    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((dynamic item) {
      final map = Map<String, dynamic>.from(item as Map);
      return ReminderModel(
        id: map['id'] as String,
        title: map['title'] as String,
        body: map['body'] as String,
        scheduledAtIso: map['scheduledAtIso'] as String,
        enabled: map['enabled'] as bool,
      );
    }).toList();
  }

  Future<void> saveAll(List<ReminderModel> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = reminders.map((ReminderModel r) {
      return <String, dynamic>{
        'id': r.id,
        'title': r.title,
        'body': r.body,
        'scheduledAtIso': r.scheduledAtIso,
        'enabled': r.enabled,
      };
    }).toList();
    await prefs.setString(_key, jsonEncode(raw));
  }
}
