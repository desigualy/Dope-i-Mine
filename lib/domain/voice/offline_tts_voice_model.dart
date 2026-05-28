class OfflineTtsVoiceModel {
  const OfflineTtsVoiceModel({
    required this.id,
    required this.label,
    required this.provider,
    required this.localeId,
    required this.accent,
    required this.perceivedVoiceType,
    required this.modelId,
    required this.modelArchiveUrl,
    required this.modelDirectoryName,
    required this.modelFileName,
    required this.tokensFileName,
    required this.dataDirectoryName,
    required this.speakerId,
    required this.licenseLabel,
    required this.sourceUrl,
    required this.qualityTier,
    required this.approximateSizeMb,
  });

  final String id;
  final String label;
  final String provider;
  final String localeId;
  final String accent;
  final String perceivedVoiceType;
  final String modelId;
  final String modelArchiveUrl;
  final String modelDirectoryName;
  final String modelFileName;
  final String tokensFileName;
  final String dataDirectoryName;
  final int speakerId;
  final String licenseLabel;
  final String sourceUrl;
  final String qualityTier;
  final int approximateSizeMb;

  bool get canDownload => modelArchiveUrl.trim().isNotEmpty;

  static const lessacMedium = OfflineTtsVoiceModel(
    id: 'sherpa_piper_en_us_lessac_medium',
    label: 'Lessac Medium',
    provider: 'sherpa_onnx',
    localeId: 'en-US',
    accent: 'US',
    perceivedVoiceType: 'calm_clear',
    modelId: 'vits-piper-en_US-lessac-medium',
    modelArchiveUrl:
        'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-piper-en_US-lessac-medium.tar.bz2',
    modelDirectoryName: 'vits-piper-en_US-lessac-medium',
    modelFileName: 'en_US-lessac-medium.onnx',
    tokensFileName: 'tokens.txt',
    dataDirectoryName: 'espeak-ng-data',
    speakerId: 0,
    licenseLabel: 'Piper voice model license; see upstream source',
    sourceUrl: 'https://github.com/k2-fsa/sherpa-onnx/releases/tag/tts-models',
    qualityTier: 'medium',
    approximateSizeMb: 80,
  );

  // Real Piper/Sherpa-compatible voices are listed here only when their
  // archive URL and on-disk contract are known. Additional entries can be
  // enabled safely by supplying verified archives via dart-define or remote
  // catalogue wiring without inventing downloads in app code.
  static const amyLow = OfflineTtsVoiceModel(
    id: 'sherpa_piper_en_us_amy_low_configurable',
    label: 'Amy Low',
    provider: 'sherpa_onnx',
    localeId: 'en-US',
    accent: 'US',
    perceivedVoiceType: 'bright',
    modelId: 'vits-piper-en_US-amy-low',
    modelArchiveUrl: String.fromEnvironment('SHERPA_ONNX_TTS_AMY_LOW_URL'),
    modelDirectoryName: 'vits-piper-en_US-amy-low',
    modelFileName: 'en_US-amy-low.onnx',
    tokensFileName: 'tokens.txt',
    dataDirectoryName: 'espeak-ng-data',
    speakerId: 0,
    licenseLabel: 'Piper voice model license; verify upstream before enabling',
    sourceUrl: 'https://github.com/k2-fsa/sherpa-onnx/releases/tag/tts-models',
    qualityTier: 'low',
    approximateSizeMb: 35,
  );

  static const alanLow = OfflineTtsVoiceModel(
    id: 'sherpa_piper_en_gb_alan_low_configurable',
    label: 'Alan Low',
    provider: 'sherpa_onnx',
    localeId: 'en-GB',
    accent: 'UK',
    perceivedVoiceType: 'steady',
    modelId: 'vits-piper-en_GB-alan-low',
    modelArchiveUrl: String.fromEnvironment('SHERPA_ONNX_TTS_ALAN_LOW_URL'),
    modelDirectoryName: 'vits-piper-en_GB-alan-low',
    modelFileName: 'en_GB-alan-low.onnx',
    tokensFileName: 'tokens.txt',
    dataDirectoryName: 'espeak-ng-data',
    speakerId: 0,
    licenseLabel: 'Piper voice model license; verify upstream before enabling',
    sourceUrl: 'https://github.com/k2-fsa/sherpa-onnx/releases/tag/tts-models',
    qualityTier: 'low',
    approximateSizeMb: 35,
  );

  static const catalogue = <OfflineTtsVoiceModel>[
    lessacMedium,
    amyLow,
    alanLow,
  ];

  static OfflineTtsVoiceModel defaultVoice() => lessacMedium;

  static OfflineTtsVoiceModel? byId(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final voice in catalogue) {
      if (voice.id == id) return voice;
    }
    return null;
  }
}

enum OfflineTtsVoiceDownloadStatus { notDownloaded, downloading, ready, failed }