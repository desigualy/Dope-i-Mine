import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/mappers/profile_mapper.dart';
import '../../domain/branding/pronunciation_option.dart';
import '../../domain/profile/sensory_settings_model.dart';
import '../../domain/profile/user_profile_model.dart';
import '../../domain/tasks/task_state_snapshot.dart';

class ProfileRepositoryImpl {
  ProfileRepositoryImpl(this._client);

  final SupabaseClient _client;

  Future<void> ensureProfileExists({
    required String userId,
    String? email,
  }) async {
    await _client.from('users_profile').upsert(<String, dynamic>{
      'id': userId,
      if (email != null) 'email': email,
    });
  }

  Future<void> setOnboardingCompleted({
    required String userId,
    String? email,
    required bool completed,
  }) async {
    await ensureProfileExists(userId: userId, email: email);
    await _client.from('users_profile').upsert(<String, dynamic>{
      'id': userId,
      if (email != null) 'email': email,
      'onboarding_completed': completed,
      'onboarding_completed_at':
          completed ? DateTime.now().toIso8601String() : null,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

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
    bool softColors = true,
    String praiseLevel = 'medium',
    bool iconMode = false,
    bool reduceSurprises = true,
  }) async {
    await ensureProfileExists(
      userId: userId,
      email: _client.auth.currentUser?.email,
    );

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
      'soft_colors': softColors,
      'praise_level': praiseLevel,
      'icon_mode': iconMode,
      'reduce_surprises': reduceSurprises,
      'updated_at': DateTime.now().toIso8601String(),
    });

    await _client.from('users_profile').upsert(<String, dynamic>{
      'id': userId,
      'email': _client.auth.currentUser?.email,
      'age_band': ageBand.name,
      'default_mode': _modeToDb(mode),
      'voice_enabled': voiceEnabled,
      'onboarding_completed': true,
      'onboarding_completed_at': DateTime.now().toIso8601String(),
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
    final row = await _client
        .from('users_profile')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (row == null) return null;
    return ProfileMapper.fromProfileRow(row);
  }

  Future<bool> isOnboardingComplete(String userId) async {
    final profileRow = await _client
        .from('users_profile')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (profileRow == null) return false;
    return profileRow['onboarding_completed'] == true;
  }

  Future<SensorySettingsModel?> getSensorySettings(String userId) async {
    final row = await _client
        .from('sensory_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null) return null;
    return ProfileMapper.fromSensoryRow(row);
  }

  Future<void> updateAssistantName(String userId, String name) async {
    await _client.from('assistant_identity_settings').upsert(<String, dynamic>{
      'user_id': userId,
      'assistant_display_name': name,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateSensorySettings(String userId, {
    bool? reducedAnimation,
    bool? largeText,
    bool? soundEnabled,
    bool? softColors,
    String? praiseLevel,
    bool? iconMode,
    bool? reduceSurprises,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (reducedAnimation != null) updates['reduced_animation'] = reducedAnimation;
    if (largeText != null) updates['large_text'] = largeText;
    if (soundEnabled != null) updates['sound_enabled'] = soundEnabled;
    if (softColors != null) updates['soft_colors'] = softColors;
    if (praiseLevel != null) updates['praise_level'] = praiseLevel;
    if (iconMode != null) updates['icon_mode'] = iconMode;
    if (reduceSurprises != null) updates['reduce_surprises'] = reduceSurprises;

    await _client.from('sensory_settings').update(updates).eq('user_id', userId);
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
