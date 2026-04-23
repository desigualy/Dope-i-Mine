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
        .map((dynamic row) =>
            RoutineMapper.fromRoutineRow(Map<String, dynamic>.from(row as Map)))
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

    if (initialSteps.isNotEmpty) {
      final inserts = initialSteps.asMap().entries.map((entry) {
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

    return RoutineMapper.fromRoutineRow(row);
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
}
