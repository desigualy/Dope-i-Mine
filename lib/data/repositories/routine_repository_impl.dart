import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/mappers/routine_mapper.dart';
import '../../domain/routines/routine_model.dart';
import '../../domain/routines/routine_step_model.dart';

class RoutineRepositoryImpl {
  RoutineRepositoryImpl(this._client);

  final SupabaseClient _client;

  Future<List<RoutineModel>> getRoutines(String userId) async {
    final rows = await _client
        .from('routines')
        .select()
        .eq('user_id', userId)
        .order('created_at');
    return (rows as List<dynamic>)
        .map((dynamic row) => RoutineMapper.fromRoutineRow(
            Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  Future<RoutineModel> createRoutine({
    required String userId,
    required String title,
    required String ageBand,
    List<String> initialSteps = const <String>[],
  }) async {
    final row = await _client
        .from('routines')
        .insert(<String, dynamic>{
          'user_id': userId,
          'title': title,
          'age_band': ageBand,
          'is_template': false,
        })
        .select()
        .single();

    final routineId = row['id'] as String;
    await replaceRoutineSteps(routineId: routineId, steps: initialSteps);

    return RoutineMapper.fromRoutineRow(row);
  }

  Future<void> updateRoutine({
    required String routineId,
    required String title,
    required String ageBand,
  }) async {
    await _client.from('routines').update(<String, dynamic>{
      'title': title,
      'age_band': ageBand,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', routineId);
  }

  Future<void> replaceRoutineSteps({
    required String routineId,
    required List<String> steps,
  }) async {
    await _client.from('routine_steps').delete().eq('routine_id', routineId);
    final cleanSteps = steps
        .map((step) => step.trim())
        .where((step) => step.isNotEmpty)
        .toList();
    if (cleanSteps.isEmpty) return;

    final inserts = cleanSteps.asMap().entries.map((entry) {
      return <String, dynamic>{
        'routine_id': routineId,
        'parent_step_id': null,
        'depth_level': 0,
        'sequence_no': entry.key + 1,
        'step_text': entry.value,
        'is_optional': false,
      };
    }).toList();
    await _client.from('routine_steps').insert(inserts);
  }

  Future<List<RoutineStepModel>> getRoutineSteps(String routineId) async {
    final rows = await _client
        .from('routine_steps')
        .select()
        .eq('routine_id', routineId)
        .order('sequence_no');

    return (rows as List<dynamic>)
        .map((dynamic row) => RoutineMapper.fromRoutineStepRow(
            Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  Future<void> deleteRoutine(String routineId) async {
    await _client.from('routine_steps').delete().eq('routine_id', routineId);
    await _client.from('routines').delete().eq('id', routineId);
  }

  Future<RoutineModel> duplicateRoutine({
    required String userId,
    required RoutineModel source,
  }) async {
    final steps = await getRoutineSteps(source.id);
    return createRoutine(
      userId: userId,
      title: 'Copy of ${source.title}',
      ageBand: source.ageBand,
      initialSteps: steps.map((step) => step.stepText).toList(),
    );
  }

  Future<void> completeStep({
    required String userId,
    required String routineId,
    required String stepId,
  }) async {
    await _client.from('progress_logs').insert(<String, dynamic>{
      'user_id': userId,
      'task_id': null,
      'step_id': stepId,
      'event_type': 'routine_step_completed',
      'metadata': <String, dynamic>{
        'routine_id': routineId,
        'idempotency_key': 'routine_${routineId}_step_$stepId',
      },
    });

    try {
      await _client.from('rewards').insert(<String, dynamic>{
        'user_id': userId,
        'reward_type': 'xp',
        'reward_key': 'routine_step_completed',
        'amount': 5,
        'source_type': 'routine_step',
        'source_id': stepId,
      });
    } catch (_) {
      // Reward writes are helpful, not critical. Progress must not fail because XP failed.
    }
  }

  Future<List<RoutineModel>> getRoutinesByAgeBand(String ageBand) async {
    final rows = await _client
        .from('routines')
        .select()
        .eq('age_band', ageBand)
        .eq('is_template', true);

    return (rows as List<dynamic>)
        .map((dynamic row) => RoutineMapper.fromRoutineRow(
            Map<String, dynamic>.from(row as Map)))
        .toList();
  }
}
