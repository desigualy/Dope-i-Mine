import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/voice/voice_profile_model.dart';
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
      localeId: row['locale_id'] as String?,
      platformVoiceName: row['platform_voice_name'] as String?,
      platformVoiceLocale: row['platform_voice_locale'] as String?,
    );
  }

  Future<void> save({
    required String userId,
    required VoiceSettingsModel settings,
  }) async {
    await _client.from('user_voice_settings').upsert(<String, dynamic>{
      'user_id': userId,
      'active_voice_profile_id': settings.activeVoiceProfileId,
      'locale_id': settings.localeId,
      'platform_voice_name': settings.platformVoiceName,
      'platform_voice_locale': settings.platformVoiceLocale,
      'speech_rate': settings.speechRate,
      'auto_read_steps': settings.autoReadSteps,
      'auto_read_sidequests': settings.autoReadSidequests,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<VoiceProfileModel>> getVoiceProfiles() async {
    try {
      final rows = await _client
          .from('voice_profiles')
          .select()
          .eq('is_active', true)
          .order('accent')
          .order('gender')
          .order('label');
      final profiles = (rows as List<dynamic>)
          .map((dynamic row) =>
              VoiceProfileModel.fromJson(Map<String, dynamic>.from(row as Map)))
          .toList();
      return profiles.isEmpty ? VoiceProfileModel.fallbacks : profiles;
    } catch (_) {
      return VoiceProfileModel.fallbacks;
    }
  }

  Future<VoiceProfileModel?> getVoiceProfile(String? profileId) async {
    if (profileId == null || profileId.isEmpty) return null;
    VoiceProfileModel? fallback;
    for (final profile in VoiceProfileModel.fallbacks) {
      if (profile.id == profileId) {
        fallback = profile;
        break;
      }
    }
    try {
      final row = await _client
          .from('voice_profiles')
          .select()
          .eq('id', profileId)
          .maybeSingle();
      if (row == null) return fallback;
      return VoiceProfileModel.fromJson(Map<String, dynamic>.from(row));
    } catch (_) {
      return fallback;
    }
  }
}
