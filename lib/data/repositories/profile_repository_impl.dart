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
    String accountType = 'user',
  }) async {
    await _acceptPendingCaregiverInvitesForEmail(email);

    final hasAcceptedCaregiverProfile = await _hasCaregiverProfile(userId);
    final hasAcceptedCaregiverRelationship =
        await _hasAcceptedCaregiverRelationship(userId);
    final hasAcceptedSupportedUserRelationship =
        await _hasAcceptedSupportedUserRelationship(userId);
    final existingAccountType = await _getStoredAccountType(userId);
    final normalizedAccountType = resolveEffectiveAccountType(
      storedAccountType: existingAccountType,
      requestedAccountType: accountType,
      hasCaregiverProfile: hasAcceptedCaregiverProfile,
      hasAcceptedCaregiverRelationship: hasAcceptedCaregiverRelationship,
      hasAcceptedSupportedUserRelationship: hasAcceptedSupportedUserRelationship,
    );
    try {
      await _client.from('users_profile').upsert(<String, dynamic>{
        'id': userId,
        if (email != null) 'email': email,
        'account_type': normalizedAccountType,
      });
    } catch (_) {
      await _client.from('users_profile').upsert(<String, dynamic>{
        'id': userId,
        if (email != null) 'email': email,
      });
    }

    if (normalizedAccountType == 'caregiver') {
      try {
        await _client.from('caregiver_profiles').upsert(<String, dynamic>{
          'user_id': userId,
          if (email != null) 'contact_email': email,
          'verification_status': 'unverified',
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {
        // Older environments may not have caregiver_profiles until the latest
        // migration is applied. Do not block login/profile bootstrap.
      }

      await _repairCaregiverCompletionIfLinked(
        userId: userId,
        email: email,
        hasAcceptedCaregiverRelationship: hasAcceptedCaregiverRelationship,
      );
    }
  }

  static String resolveEffectiveAccountType({
    required String? storedAccountType,
    required String? requestedAccountType,
    required bool hasCaregiverProfile,
    required bool hasAcceptedCaregiverRelationship,
    required bool hasAcceptedSupportedUserRelationship,
  }) {
    final explicitlyRequestedCaregiver = requestedAccountType == 'caregiver';

    if (explicitlyRequestedCaregiver ||
        hasCaregiverProfile ||
        hasAcceptedCaregiverRelationship) {
      return 'caregiver';
    }

    // A supported user has a relationship row, but they are not the caregiver.
    // Never promote them into caregiver routing because of support linkage.
    if (hasAcceptedSupportedUserRelationship) return 'user';

    // Stored account_type is intentionally not authoritative on its own. Older
    // builds could accidentally persist `caregiver`; require a caregiver profile
    // or caregiver-side accepted relationship before routing to caregiver pages.
    return 'user';
  }

  Future<String?> _getStoredAccountType(String userId) async {
    try {
      final profileRow = await _client
          .from('users_profile')
          .select('account_type')
          .eq('id', userId)
          .maybeSingle();
      final accountType = profileRow?['account_type'];
      return accountType is String ? accountType : null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> _hasAcceptedCaregiverRelationship(String userId) async {
    try {
      final relationships = await _client
          .from('caregiver_relationships')
          .select('id')
          .eq('caregiver_user_id', userId)
          .eq('status', 'accepted')
          .limit(1);
      return (relationships as List).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _hasCaregiverProfile(String userId) async {
    try {
      final profile = await _client
          .from('caregiver_profiles')
          .select('user_id')
          .eq('user_id', userId)
          .maybeSingle();
      return profile != null;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _hasAcceptedSupportedUserRelationship(String userId) async {
    try {
      final relationships = await _client
          .from('caregiver_relationships')
          .select('id')
          .eq('supported_user_id', userId)
          .eq('status', 'accepted')
          .limit(1);
      return (relationships as List).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _repairCaregiverCompletionIfLinked({
    required String userId,
    String? email,
    bool hasAcceptedCaregiverRelationship = false,
  }) async {
    try {
      if (!hasAcceptedCaregiverRelationship &&
          !await _hasAcceptedCaregiverRelationship(userId)) {
        return;
      }

      await _client.from('users_profile').upsert(<String, dynamic>{
        'id': userId,
        if (email != null) 'email': email,
        'account_type': 'caregiver',
        'onboarding_completed': true,
        'onboarding_completed_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Older environments may not have caregiver relationship tables/RPCs yet.
      // Do not block login/profile bootstrap.
    }
  }

  Future<void> _acceptPendingCaregiverInvitesForEmail(String? email) async {
    if (email == null || !email.contains('@')) return;
    try {
      await _client.rpc('accept_pending_caregiver_email_invites');
    } catch (_) {
      // The RPC is security-definer because invitees cannot read pending
      // caregiver_email_invites rows under RLS. Do not block login/profile
      // bootstrap if older environments do not have the RPC yet.
    }
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
    String? sexAtBirth,
    String? genderIdentity,
    String? pronouns,
    String? customPronouns,
    String? onboardingRole,
    bool? notificationsEnabled,
    bool? bodyDoubleEnabled,
    bool? sideQuestsEnabled,
  }) async {
    await ensureProfileExists(
      userId: userId,
      email: _client.auth.currentUser?.email,
    );

    final now = DateTime.now().toIso8601String();

    try {
      await _client.from('users_profile').upsert(<String, dynamic>{
        'id': userId,
        'email': _client.auth.currentUser?.email,
        'age_band': ageBand.name,
        'default_mode': _modeToDb(mode),
        'voice_enabled': voiceEnabled,
        'sex_at_birth': sexAtBirth,
        'gender_identity': genderIdentity,
        'pronouns': pronouns,
        'custom_pronouns': customPronouns,
        'onboarding_role': onboardingRole,
        'notifications_enabled': notificationsEnabled,
        'body_double_enabled': bodyDoubleEnabled,
        'side_quests_enabled': sideQuestsEnabled,
        'onboarding_completed': true,
        'onboarding_completed_at': now,
        'updated_at': now,
      });
    } catch (_) {
      // Some live/staged databases may lag behind optional profile-field
      // migrations. Finishing onboarding must still persist the explicit
      // completion flag so users are not trapped on the summary screen.
      await _client.from('users_profile').upsert(<String, dynamic>{
        'id': userId,
        'email': _client.auth.currentUser?.email,
        'onboarding_completed': true,
        'onboarding_completed_at': now,
        'updated_at': now,
      });
    }

    try {
      await _client
          .from('assistant_identity_settings')
          .upsert(<String, dynamic>{
        'user_id': userId,
        'assistant_display_name': assistantDisplayName,
        'pronunciation_key': _pronunciationKey(pronunciation),
        'updated_at': now,
      });
    } catch (_) {
      // Optional settings should not block onboarding completion.
    }

    try {
      await _client.from('sensory_settings').upsert(<String, dynamic>{
        'user_id': userId,
        'reduced_animation': reducedAnimation,
        'large_text': largeText,
        'sound_enabled': soundEnabled,
        'soft_colors': softColors,
        'praise_level': praiseLevel,
        'icon_mode': iconMode,
        'reduce_surprises': reduceSurprises,
        'updated_at': now,
      });
    } catch (_) {
      // Optional settings should not block onboarding completion.
    }
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

  Future<bool> areSideQuestsEnabled(String userId) async {
    try {
      final profileRow = await _client
          .from('users_profile')
          .select('side_quests_enabled')
          .eq('id', userId)
          .maybeSingle();
      return profileRow?['side_quests_enabled'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<String> getAccountType(String userId) async {
    try {
      final profileRow = await _client
          .from('users_profile')
          .select('account_type')
          .eq('id', userId)
          .maybeSingle();

      final hasCaregiverProfile = await _hasCaregiverProfile(userId);
      final hasCaregiverRelationship =
          await _hasAcceptedCaregiverRelationship(userId);
      final hasSupportedUserRelationship =
          await _hasAcceptedSupportedUserRelationship(userId);

      final storedAccountType = profileRow?['account_type'];
      return resolveEffectiveAccountType(
        storedAccountType: storedAccountType is String ? storedAccountType : null,
        requestedAccountType: null,
        hasCaregiverProfile: hasCaregiverProfile,
        hasAcceptedCaregiverRelationship: hasCaregiverRelationship,
        hasAcceptedSupportedUserRelationship: hasSupportedUserRelationship,
      );
    } catch (_) {
      return 'user';
    }
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

  Future<void> updateSensorySettings(
    String userId, {
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
    if (reducedAnimation != null) {
      updates['reduced_animation'] = reducedAnimation;
    }
    if (largeText != null) updates['large_text'] = largeText;
    if (soundEnabled != null) updates['sound_enabled'] = soundEnabled;
    if (softColors != null) updates['soft_colors'] = softColors;
    if (praiseLevel != null) updates['praise_level'] = praiseLevel;
    if (iconMode != null) updates['icon_mode'] = iconMode;
    if (reduceSurprises != null) updates['reduce_surprises'] = reduceSurprises;

    await _client
        .from('sensory_settings')
        .update(updates)
        .eq('user_id', userId);
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

  Future<bool> mustChangePassword(String userId) async {
    try {
      final profileRow = await _client
          .from('users_profile')
          .select('must_change_password')
          .eq('id', userId)
          .maybeSingle();
      if (profileRow == null) return false;
      return profileRow['must_change_password'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearMustChangePassword({
    required String userId,
  }) async {
    await _client.from('users_profile').update(<String, dynamic>{
      'must_change_password': false,
      'temporary_password_created_at': null,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }
}
