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

  Future<List<Map<String, dynamic>>> getCompletedTasks(String userId) async {
    final rows = await _client
        .from('tasks')
        .select('*, task_steps(completion_status)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (rows as List<dynamic>)
        .map((dynamic row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }

  Future<int> getReliabilityScore(String userId) async {
    final res = await _client
        .from('users_profile')
        .select('reliability_score')
        .eq('id', userId)
        .maybeSingle();
    final rawScore = (res?['reliability_score'] as num?) ?? 1.0;
    return rawScore <= 1 ? (rawScore * 100).round() : rawScore.round();
  }

  Future<List<Map<String, dynamic>>> getRecentTaskContext(String userId) async {
    final rows = await _client
        .from('tasks')
        .select(
          'id, normalized_title, mode_used, energy_level, stress_level, time_available, effort_band, estimated_minutes, created_at, task_steps(completion_status)',
        )
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(14);

    return (rows as List<dynamic>)
        .map((dynamic row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }
}
