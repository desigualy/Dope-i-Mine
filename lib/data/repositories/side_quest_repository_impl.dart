import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/sidequests/side_quest_model.dart';

class SideQuestRepositoryImpl {
  SideQuestRepositoryImpl(this._client);

  final SupabaseClient _client;

  Future<List<SideQuestModel>> getAvailableForTask(String userId, String taskId) async {
    final rows = await _client
        .from('side_quests')
        .select()
        .eq('user_id', userId)
        .eq('task_id', taskId)
        .inFilter('status', <String>['available', 'accepted'])
        .order('created_at');

    return (rows as List<dynamic>).map((dynamic row) {
      final map = Map<String, dynamic>.from(row as Map);
      return SideQuestModel(
        id: map['id'] as String,
        title: map['title'] as String,
        questType: map['quest_type'] as String,
        rewardXp: map['reward_xp'] as int,
        status: map['status'] as String,
        taskId: map['task_id'] as String?,
        routineId: map['routine_id'] as String?,
      );
    }).toList();
  }

  Future<void> accept(String sideQuestId) async {
    await _client
        .from('side_quests')
        .update(<String, dynamic>{'status': 'accepted'})
        .eq('id', sideQuestId);
  }

  Future<void> complete({
    required String userId,
    required String sideQuestId,
  }) async {
    final row = await _client
        .from('side_quests')
        .update(<String, dynamic>{
          'status': 'completed',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', sideQuestId)
        .select()
        .single();

    await _client.from('rewards').insert(<String, dynamic>{
      'user_id': userId,
      'reward_type': 'xp',
      'reward_key': 'side_quest_complete',
      'source_type': 'side_quest',
      'source_id': sideQuestId,
    });

    await _client.from('progress_logs').insert(<String, dynamic>{
      'user_id': userId,
      'task_id': row['task_id'],
      'event_type': 'side_quest_completed',
      'metadata': <String, dynamic>{'sideQuestId': sideQuestId},
    });
  }

  Future<void> dismiss(String sideQuestId) async {
    await _client
        .from('side_quests')
        .update(<String, dynamic>{'status': 'dismissed'})
        .eq('id', sideQuestId);
  }
}
