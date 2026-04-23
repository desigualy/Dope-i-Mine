import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/caregiver/caregiver_assigned_routine_model.dart';

class CaregiverAssignmentsRepositoryImpl {
  CaregiverAssignmentsRepositoryImpl(this._client);

  final SupabaseClient _client;

  Future<void> assignRoutine({
    required String caregiverUserId,
    required String targetUserId,
    required String routineId,
  }) async {
    await _client.from('caregiver_assigned_routines').upsert(<String, dynamic>{
      'caregiver_user_id': caregiverUserId,
      'target_user_id': targetUserId,
      'routine_id': routineId,
      'status': 'active',
    });
  }

  Future<List<CaregiverAssignedRoutineModel>> getAssignedToUser(
    String targetUserId,
  ) async {
    final rows = await _client
        .from('caregiver_assigned_routines')
        .select()
        .eq('target_user_id', targetUserId)
        .order('assigned_at', ascending: false);

    return (rows as List<dynamic>).map((dynamic row) {
      final map = Map<String, dynamic>.from(row as Map);
      return CaregiverAssignedRoutineModel(
        id: map['id'] as String,
        caregiverUserId: map['caregiver_user_id'] as String,
        targetUserId: map['target_user_id'] as String,
        routineId: map['routine_id'] as String,
        status: map['status'] as String,
      );
    }).toList();
  }
}
