class VoiceProfileModel {
  const VoiceProfileModel({
    required this.id,
    required this.provider,
    required this.label,
    required this.localeId,
    required this.accent,
    required this.gender,
    required this.pace,
    required this.warmth,
    required this.firmness,
    required this.tonePreset,
    this.platformVoiceName,
    this.offlineVoiceId,
    this.isActive = true,
  });

  final String id;
  final String provider;
  final String label;
  final String localeId;
  final String accent;
  final String gender;
  final String pace;
  final String warmth;
  final String firmness;
  final String tonePreset;
  final String? platformVoiceName;
  final String? offlineVoiceId;
  final bool isActive;

  double get defaultRate {
    return switch (pace) {
      'slow' => 0.40,
      'bright' => 0.52,
      'fast' => 0.58,
      _ => 0.46,
    };
  }

  double get defaultPitch {
    final base = gender == 'female' ? 1.05 : 0.95;
    return warmth == 'high' ? base + 0.02 : base;
  }

  factory VoiceProfileModel.fromJson(Map<String, dynamic> row) {
    return VoiceProfileModel(
      id: row['id'] as String,
      provider: row['provider'] as String? ?? 'system',
      label: row['label'] as String? ?? 'System voice',
      localeId: row['locale_id'] as String? ??
          (row['accent'] == 'US' ? 'en-US' : 'en-GB'),
      accent: row['accent'] as String? ?? 'UK',
      gender: row['gender'] as String? ?? 'neutral',
      pace: row['pace'] as String? ?? 'normal',
      warmth: row['warmth'] as String? ?? 'medium',
      firmness: row['firmness'] as String? ?? 'medium',
      tonePreset: row['tone_preset'] as String? ?? row['id'] as String,
      platformVoiceName: row['platform_voice_name'] as String?,
      offlineVoiceId: row['offline_voice_id'] as String?,
      isActive: row['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'provider': provider,
        'label': label,
        'locale_id': localeId,
        'accent': accent,
        'gender': gender,
        'pace': pace,
        'warmth': warmth,
        'firmness': firmness,
        'tone_preset': tonePreset,
        'platform_voice_name': platformVoiceName,
        'offline_voice_id': offlineVoiceId,
        'is_active': isActive,
      };

  static const List<VoiceProfileModel> fallbacks = <VoiceProfileModel>[
    VoiceProfileModel(
        id: 'uk_female_calm_guide',
        provider: 'system',
        label: 'UK Female — Calm Guide',
        localeId: 'en-GB',
        accent: 'UK',
        gender: 'female',
        pace: 'slow',
        warmth: 'high',
        firmness: 'low',
        tonePreset: 'uk_female_calm_guide'),
    VoiceProfileModel(
        id: 'uk_female_bright_coach',
        provider: 'system',
        label: 'UK Female — Bright Coach',
        localeId: 'en-GB',
        accent: 'UK',
        gender: 'female',
        pace: 'bright',
        warmth: 'medium',
        firmness: 'medium',
        tonePreset: 'uk_female_bright_coach'),
    VoiceProfileModel(
        id: 'uk_male_steady_guide',
        provider: 'system',
        label: 'UK Male — Steady Guide',
        localeId: 'en-GB',
        accent: 'UK',
        gender: 'male',
        pace: 'normal',
        warmth: 'medium',
        firmness: 'medium',
        tonePreset: 'uk_male_steady_guide'),
    VoiceProfileModel(
        id: 'uk_male_focus_coach',
        provider: 'system',
        label: 'UK Male — Focus Coach',
        localeId: 'en-GB',
        accent: 'UK',
        gender: 'male',
        pace: 'normal',
        warmth: 'low',
        firmness: 'high',
        tonePreset: 'uk_male_focus_coach'),
    VoiceProfileModel(
        id: 'us_female_gentle_companion',
        provider: 'system',
        label: 'US Female — Gentle Companion',
        localeId: 'en-US',
        accent: 'US',
        gender: 'female',
        pace: 'slow',
        warmth: 'high',
        firmness: 'low',
        tonePreset: 'us_female_gentle_companion'),
    VoiceProfileModel(
        id: 'us_female_practical_coach',
        provider: 'system',
        label: 'US Female — Practical Coach',
        localeId: 'en-US',
        accent: 'US',
        gender: 'female',
        pace: 'normal',
        warmth: 'medium',
        firmness: 'high',
        tonePreset: 'us_female_practical_coach'),
    VoiceProfileModel(
        id: 'us_male_warm_mentor',
        provider: 'system',
        label: 'US Male — Warm Mentor',
        localeId: 'en-US',
        accent: 'US',
        gender: 'male',
        pace: 'normal',
        warmth: 'high',
        firmness: 'medium',
        tonePreset: 'us_male_warm_mentor'),
    VoiceProfileModel(
        id: 'us_male_direct_coach',
        provider: 'system',
        label: 'US Male — Direct Coach',
        localeId: 'en-US',
        accent: 'US',
        gender: 'male',
        pace: 'bright',
        warmth: 'low',
        firmness: 'high',
        tonePreset: 'us_male_direct_coach'),
  ];
}
