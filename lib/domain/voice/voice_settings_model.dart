class VoiceSettingsModel {
  const VoiceSettingsModel({
    required this.activeVoiceProfileId,
    required this.speechRate,
    required this.autoReadSteps,
    required this.autoReadSidequests,
    this.localeId,
    this.platformVoiceName,
    this.platformVoiceLocale,
  });

  final String? activeVoiceProfileId;
  final double speechRate;
  final bool autoReadSteps;
  final bool autoReadSidequests;
  final String? localeId;
  final String? platformVoiceName;
  final String? platformVoiceLocale;

  factory VoiceSettingsModel.fromJson(Map<String, dynamic> json) {
    return VoiceSettingsModel(
      activeVoiceProfileId: json['activeVoiceProfileId'] as String?,
      speechRate: (json['speechRate'] as num?)?.toDouble() ?? 1.0,
      autoReadSteps: json['autoReadSteps'] as bool? ?? false,
      autoReadSidequests: json['autoReadSidequests'] as bool? ?? false,
      localeId: json['localeId'] as String?,
      platformVoiceName: json['platformVoiceName'] as String?,
      platformVoiceLocale: json['platformVoiceLocale'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'activeVoiceProfileId': activeVoiceProfileId,
      'speechRate': speechRate,
      'autoReadSteps': autoReadSteps,
      'autoReadSidequests': autoReadSidequests,
      'localeId': localeId,
      'platformVoiceName': platformVoiceName,
      'platformVoiceLocale': platformVoiceLocale,
    };
  }
}
