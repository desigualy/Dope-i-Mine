import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/mappers/profile_mapper.dart';
import '../../domain/branding/pronunciation_option.dart';
import '../../domain/profile/sensory_settings_model.dart';
import '../../domain/profile/user_profile_model.dart';
import '../../domain/tasks/task_state_snapshot.dart';

class ProfileRepositoryImpl {
  ProfileRepositoryImpl(this._client);

  final SupabaseClient _client;

  Future<void> saveOnboardingProfile({
    required String userId,
    required AgeBand ageBand,
    required SupportMode mode,
    required String assistantDisplayName,
    required PronunciationOption pronunciation,
    required bool voiceEnabled,
    required bool reducedAnimation,
    required bool largeText,
    required bool soundEnabled,
  }) async {
    await _client.from('users_profile').upsert(<String, dynamic>{
      'id': userId,
      'age_band': ageBand.name,
      'default_mode': _modeToDb(mode),
      'voice_enabled': voiceEnabled,
      'updated_at': DateTime.now().toIso8601String(),
    });

    await _client.from('assistant_identity_settings').upsert(<String, dynamic>{
      'user_id': userId,
      'assistant_display_name': assistantDisplayName,
      'pronunciation_key': _pronunciationKey(pronunciation),
      'updated_at': DateTime.now().toIso8601String(),
    });

    await _client.from('sensory_settings').upsert(<String, dynamic>{
      'user_id': userId,
      'reduced_animation': reducedAnimation,
      'large_text': largeText,
      'sound_enabled': soundEnabled,
      'soft_colors': true,
      'praise_level': 'medium',
      'icon_mode': false,
      'reduce_surprises': true,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  String _pronunciationKey(PronunciationOption option) {
    return switch (option) {
      PronunciationOption.dopeEe => 'dope_ee',
      PronunciationOption.dopy => 'dopy',
      PronunciationOption.dopeEye => 'dope_eye',
      PronunciationOption.custom => 'custom',
    };
  }

  Future<UserProfileModel?> getProfile(String userId) async {
    final row = await _client.from('users_profile').select().eq('id', userId).maybeSingle();
    if (row == null) return null;
    return ProfileMapper.fromProfileRow(row);
  }

  Future<SensorySettingsModel?> getSensorySettings(String userId) async {
    final row = await _client.from('sensory_settings').select().eq('user_id', userId).maybeSingle();
    if (row == null) return null;
    return ProfileMapper.fromSensoryRow(row);
  }

  String _modeToDb(SupportMode mode) {
    return switch (mode) {
      SupportMode.adhd => 'adhd',
      SupportMode.autism => 'autism',
      SupportMode.audhd => 'audhd',
      SupportMode.executiveDysfunction => 'executive_dysfunction',
      SupportMode.burnout => 'burnout',
    };
  }
}
