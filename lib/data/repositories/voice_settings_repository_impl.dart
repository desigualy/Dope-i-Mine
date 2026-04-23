import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/voice/voice_settings_model.dart';

class VoiceSettingsRepositoryImpl {
  VoiceSettingsRepositoryImpl(this._client);

  final SupabaseClient _client;

  Future<VoiceSettingsModel?> getSettings(String userId) async {
    final row = await _client
        .from('user_voice_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null) return null;

    return VoiceSettingsModel(
      activeVoiceProfileId: row['active_voice_profile_id'] as String?,
      speechRate: (row['speech_rate'] as num).toDouble(),
      autoReadSteps: row['auto_read_steps'] as bool? ?? false,
      autoReadSidequests: row['auto_read_sidequests'] as bool? ?? false,
    );
  }

  Future<void> save({
    required String userId,
    required VoiceSettingsModel settings,
  }) async {
    await _client.from('user_voice_settings').upsert(<String, dynamic>{
      'user_id': userId,
      'active_voice_profile_id': settings.activeVoiceProfileId,
      'speech_rate': settings.speechRate,
      'auto_read_steps': settings.autoReadSteps,
      'auto_read_sidequests': settings.autoReadSidequests,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getVoiceProfiles() async {
    final rows = await _client
        .from('voice_profiles')
        .select()
        .eq('is_active', true)
        .order('label');
    return (rows as List<dynamic>)
        .map((dynamic row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }
}
