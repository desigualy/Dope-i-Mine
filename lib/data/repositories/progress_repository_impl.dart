import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/progress/progress_log_model.dart';

class ProgressRepositoryImpl {
  ProgressRepositoryImpl(this._client);

  final SupabaseClient _client;

  Future<List<ProgressLogModel>> getRecentProgress(String userId) async {
    final rows = await _client
        .from('progress_logs')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(30);

    return (rows as List<dynamic>).map((dynamic row) {
      final map = Map<String, dynamic>.from(row as Map);
      return ProgressLogModel(
        id: map['id'] as String,
        eventType: map['event_type'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        taskId: map['task_id'] as String?,
        stepId: map['step_id'] as String?,
      );
    }).toList();
  }
}
