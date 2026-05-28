import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/neural_tts_service.dart';
import '../../core/services/sherpa_onnx_text_to_speech_service.dart';
import '../../core/services/speech_to_text_service.dart';
import '../../core/services/text_to_speech_service.dart';
import '../../domain/voice/voice_profile_model.dart';
import '../../domain/voice/voice_settings_model.dart';
import '../../providers.dart';

final voiceControllerProvider = Provider<VoiceController>((ref) {
  return VoiceController(
    ref,
    ref.watch(speechToTextServiceProvider),
    ref.watch(sherpaOnnxTextToSpeechServiceProvider),
    ref.watch(neuralTtsServiceProvider),
    ref.watch(textToSpeechServiceProvider),
  );
});

class VoiceController {
  VoiceController(
    this._ref,
    this._stt,
    this._sherpaTts,
    this._neuralTts,
    this._tts,
  );

  final Ref _ref;
  final SpeechToTextService _stt;
  final SherpaOnnxTextToSpeechService _sherpaTts;
  final NeuralTtsService _neuralTts;
  final TextToSpeechService _tts;

  Future<void> speakStep(
    String text, {
    VoiceProfileModel? previewProfile,
    double? previewSpeechRate,
  }) async {
    final resolved = await _resolveVoice();
    final profile = previewProfile ?? resolved.profile;
    final rate = previewSpeechRate ?? resolved.settings?.speechRate;
    final platformVoiceName = previewProfile?.platformVoiceName ??
        resolved.settings?.platformVoiceName ??
        profile?.platformVoiceName;
    final platformVoiceLocale = previewProfile?.localeId ??
        resolved.settings?.platformVoiceLocale ??
        resolved.settings?.localeId ??
        profile?.localeId;

    if (platformVoiceName != null && platformVoiceName.isNotEmpty) {
      await _speakWithPlatformTts(
        text,
        profile: profile,
        speechRate: rate,
        platformVoiceName: platformVoiceName,
        platformVoiceLocale: platformVoiceLocale,
      );
      return;
    }

    if (_canUseSherpaFor(profile)) {
      final usedSherpa = await _sherpaTts.speak(
        text: text,
        profile: profile,
        speechRate: rate,
      );
      if (usedSherpa) return;
    }

    final usedNeural = await _neuralTts.speak(
      text: text,
      profile: profile,
      speechRate: rate,
    );
    if (usedNeural) return;

    await _speakWithPlatformTts(
      text,
      profile: profile,
      speechRate: rate,
      platformVoiceName: platformVoiceName,
      platformVoiceLocale: platformVoiceLocale,
    );
  }

  Future<void> _speakWithPlatformTts(
    String text, {
    VoiceProfileModel? profile,
    double? speechRate,
    String? platformVoiceName,
    String? platformVoiceLocale,
  }) async {
    await _tts.initialize(
      profile: profile,
      speechRate: speechRate,
      platformVoiceName: platformVoiceName,
      platformVoiceLocale: platformVoiceLocale,
    );
    await _tts.speak(text);
  }

  bool _canUseSherpaFor(VoiceProfileModel? profile) {
    return profile?.provider == 'sherpa_onnx';
  }

  Future<void> stopSpeaking() async {
    await _sherpaTts.stop();
    await _neuralTts.stop();
    await _tts.stop();
  }

  Future<void> listenForTask(void Function(String text) onResult) async {
    final ready = await _stt.initialize();
    if (!ready) return;
    final resolved = await _resolveVoice();
    await _stt.listen(onResult, localeId: resolved.profile?.localeId);
  }

  Future<_ResolvedVoice> _resolveVoice() async {
    try {
      final settings = await _ref.read(voiceSettingsProvider.future);
      final repo = _ref.read(voiceSettingsRepositoryProvider);
      final profile =
          await repo.getVoiceProfile(settings?.activeVoiceProfileId);
      return _ResolvedVoice(settings: settings, profile: profile);
    } catch (_) {
      return const _ResolvedVoice();
    }
  }
}

class _ResolvedVoice {
  const _ResolvedVoice({this.settings, this.profile});

  final VoiceSettingsModel? settings;
  final VoiceProfileModel? profile;
}
