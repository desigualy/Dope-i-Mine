class VoiceSettingsModel {
  const VoiceSettingsModel({
    required this.activeVoiceProfileId,
    required this.speechRate,
    required this.autoReadSteps,
    required this.autoReadSidequests,
    this.localeId,
  });

  final String? activeVoiceProfileId;
  final double speechRate;
  final bool autoReadSteps;
  final bool autoReadSidequests;
  final String? localeId;
}
