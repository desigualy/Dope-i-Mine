import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/companion/avatar_config_model.dart';
import '../../domain/companion/companion_model.dart';

class CompanionRepositoryImpl {
  CompanionRepositoryImpl(this._client);

  final SupabaseClient _client;

  Future<List<CompanionModel>> getCompanions() async {
    final rows = await _client.from('companions').select().order('name');
    return (rows as List<dynamic>).map((dynamic row) {
      final map = Map<String, dynamic>.from(row as Map);
      return CompanionModel(
        id: map['id'] as String,
        name: map['name'] as String,
        style: map['style'] as String,
      );
    }).toList();
  }

  Future<void> setActiveCompanion({
    required String userId,
    required String companionId,
  }) async {
    await _client
        .from('user_companions')
        .update(<String, dynamic>{'is_active': false})
        .eq('user_id', userId);

    final existing = await _client
        .from('user_companions')
        .select('id')
        .eq('user_id', userId)
        .eq('companion_id', companionId)
        .maybeSingle();

    if (existing == null) {
      await _client.from('user_companions').insert(<String, dynamic>{
        'user_id': userId,
        'companion_id': companionId,
        'is_active': true,
        'outfit_data': <String, dynamic>{},
      });
    } else {
      await _client
          .from('user_companions')
          .update(<String, dynamic>{'is_active': true})
          .eq('id', existing['id']);
    }
  }

  Future<AvatarConfigModel?> getAvatarConfig(String userId) async {
    final row = await _client
        .from('user_avatar_config')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null) return null;
    return AvatarConfigModel(
      avatarStyle: row['avatar_style'] as String,
      avatarPalette: row['avatar_palette'] as String,
      accessoryConfig: Map<String, dynamic>.from(row['accessory_config'] as Map),
    );
  }

  Future<void> saveAvatarConfig({
    required String userId,
    required AvatarConfigModel config,
  }) async {
    await _client.from('user_avatar_config').upsert(<String, dynamic>{
      'user_id': userId,
      'avatar_style': config.avatarStyle,
      'avatar_palette': config.avatarPalette,
      'accessory_config': config.accessoryConfig,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
