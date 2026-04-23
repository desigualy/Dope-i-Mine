import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/caregiver/caregiver_link_model.dart';

class CaregiverRepositoryImpl {
  CaregiverRepositoryImpl(this._client);

  final SupabaseClient _client;

  Future<void> linkCaregiver({
    required String primaryUserId,
    required String caregiverUserId,
    required String permissionLevel,
  }) async {
    await _client.from('caregiver_links').insert(<String, dynamic>{
      'primary_user_id': primaryUserId,
      'caregiver_user_id': caregiverUserId,
      'permission_level': permissionLevel,
    });
  }

  Future<List<CaregiverLinkModel>> getLinks(String userId) async {
    final rows = await _client
        .from('caregiver_links')
        .select()
        .or('primary_user_id.eq.$userId,caregiver_user_id.eq.$userId');

    return (rows as List<dynamic>).map((dynamic row) {
      final map = Map<String, dynamic>.from(row as Map);
      return CaregiverLinkModel(
        id: map['id'] as String,
        primaryUserId: map['primary_user_id'] as String,
        caregiverUserId: map['caregiver_user_id'] as String,
        permissionLevel: map['permission_level'] as String,
      );
    }).toList();
  }
}
