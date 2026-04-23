import '../../domain/profile/sensory_settings_model.dart';
import '../../domain/profile/user_profile_model.dart';
import '../../domain/tasks/task_state_snapshot.dart';

class ProfileMapper {
  static UserProfileModel fromProfileRow(Map<String, dynamic> row) {
    return UserProfileModel(
      id: row['id'] as String,
      role: row['role'] as String? ?? 'self',
      ageBand: _ageBandFromDb(row['age_band'] as String? ?? 'adult'),
      defaultMode: _modeFromDb(row['default_mode'] as String? ?? 'audhd'),
      rewardPreference: row['reward_preference'] as String? ?? 'balanced',
      stimulationLevel: row['stimulation_level'] as String? ?? 'medium',
      readingSupportLevel: row['reading_support_level'] as String? ?? 'standard',
      voiceEnabled: row['voice_enabled'] as bool? ?? true,
      displayName: row['display_name'] as String?,
    );
  }

  static SensorySettingsModel fromSensoryRow(Map<String, dynamic> row) {
    return SensorySettingsModel(
      reducedAnimation: row['reduced_animation'] as bool? ?? false,
      largeText: row['large_text'] as bool? ?? false,
      softColors: row['soft_colors'] as bool? ?? true,
      soundEnabled: row['sound_enabled'] as bool? ?? true,
      praiseLevel: row['praise_level'] as String? ?? 'medium',
      iconMode: row['icon_mode'] as bool? ?? false,
      reduceSurprises: row['reduce_surprises'] as bool? ?? true,
    );
  }

  static AgeBand _ageBandFromDb(String value) {
    switch (value) {
      case 'child':
        return AgeBand.child;
      case 'preteen':
        return AgeBand.preteen;
      case 'teen':
        return AgeBand.teen;
      default:
        return AgeBand.adult;
    }
  }

  static SupportMode _modeFromDb(String value) {
    switch (value) {
      case 'adhd':
        return SupportMode.adhd;
      case 'autism':
        return SupportMode.autism;
      case 'executive_dysfunction':
        return SupportMode.executiveDysfunction;
      case 'burnout':
        return SupportMode.burnout;
      default:
        return SupportMode.audhd;
    }
  }
}
