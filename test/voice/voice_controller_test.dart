import 'package:dope_i_mine/core/services/neural_tts_service.dart';
import 'package:dope_i_mine/core/services/sherpa_onnx_text_to_speech_service.dart';
import 'package:dope_i_mine/core/services/speech_to_text_service.dart';
import 'package:dope_i_mine/core/services/text_to_speech_service.dart';
import 'package:dope_i_mine/domain/voice/installed_tts_voice_model.dart';
import 'package:dope_i_mine/domain/voice/offline_tts_voice_model.dart';
import 'package:dope_i_mine/domain/voice/voice_profile_model.dart';
import 'package:dope_i_mine/presentation/voice/voice_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSpeechToTextService implements SpeechToTextService {
  @override
  Future<bool> initialize() async => true;

  @override
  Future<void> listen(void Function(String text) onResult, {String? localeId}) async {}

  @override
  Future<void> stop() async {}
}

class _FakeSherpaTts implements SherpaOnnxTextToSpeechService {
  int speakCalls = 0;

  @override
  Future<bool> speak({
    required String text,
    VoiceProfileModel? profile,
    double? speechRate,
    OfflineTtsVoiceModel? offlineVoice,
  }) async {
    speakCalls += 1;
    return false;
  }

  @override
  Future<void> stop() async {}

  @override
  Future<OfflineTtsVoiceDownloadStatus> downloadStatus(
    OfflineTtsVoiceModel voice,
  ) async =>
      OfflineTtsVoiceDownloadStatus.failed;
}

class _FakeNeuralTts implements NeuralTtsService {
  int speakCalls = 0;

  @override
  Future<bool> speak({
    required String text,
    VoiceProfileModel? profile,
    double? speechRate,
  }) async {
    speakCalls += 1;
    return false;
  }

  @override
  Future<void> stop() async {}
}

class _FakeTextToSpeechService implements TextToSpeechService {
  String? platformVoiceName;
  String? platformVoiceLocale;
  VoiceProfileModel? profile;
  double? speechRate;
  final spokenTexts = <String>[];

  @override
  Future<void> initialize({
    VoiceProfileModel? profile,
    double? speechRate,
    String? platformVoiceName,
    String? platformVoiceLocale,
  }) async {
    this.profile = profile;
    this.speechRate = speechRate;
    this.platformVoiceName = platformVoiceName;
    this.platformVoiceLocale = platformVoiceLocale;
  }

  @override
  Future<List<InstalledTtsVoiceModel>> installedVoices() async =>
      const <InstalledTtsVoiceModel>[];

  @override
  Future<void> speak(String text) async {
    spokenTexts.add(text);
  }

  @override
  Future<void> stop() async {}
}

void main() {
  test('VoiceController passes previewProfile platformVoiceName into TTS',
      () async {
    final sherpa = _FakeSherpaTts();
    final neural = _FakeNeuralTts();
    final platformTts = _FakeTextToSpeechService();
    final provider = Provider<VoiceController>((ref) {
      return VoiceController(
        ref,
        _FakeSpeechToTextService(),
        sherpa,
        neural,
        platformTts,
      );
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);
    const previewProfile = VoiceProfileModel(
      id: 'android-installed',
      provider: 'system',
      label: 'Android installed voice',
      localeId: 'en-US',
      accent: 'US',
      gender: 'neutral',
      pace: 'normal',
      warmth: 'medium',
      firmness: 'medium',
      tonePreset: 'platform_system_voice',
      platformVoiceName: 'en-us-x-sfg-network',
    );

    await container.read(provider).speakStep(
          'Preview this voice.',
          previewProfile: previewProfile,
          previewSpeechRate: 0.85,
        );

    expect(platformTts.platformVoiceName, 'en-us-x-sfg-network');
    expect(platformTts.platformVoiceLocale, 'en-US');
    expect(platformTts.speechRate, 0.85);
    expect(platformTts.spokenTexts, <String>['Preview this voice.']);
    expect(sherpa.speakCalls, 0);
    expect(neural.speakCalls, 0);
  });

  test('VoiceController does not use single Sherpa model for system profiles',
      () async {
    final sherpa = _FakeSherpaTts();
    final neural = _FakeNeuralTts();
    final platformTts = _FakeTextToSpeechService();
    final provider = Provider<VoiceController>((ref) {
      return VoiceController(
        ref,
        _FakeSpeechToTextService(),
        sherpa,
        neural,
        platformTts,
      );
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);
    const systemProfile = VoiceProfileModel(
      id: 'uk_female_calm_guide',
      provider: 'system',
      label: 'UK Female — Calm Guide',
      localeId: 'en-GB',
      accent: 'UK',
      gender: 'female',
      pace: 'slow',
      warmth: 'high',
      firmness: 'low',
      tonePreset: 'uk_female_calm_guide',
    );

    await container.read(provider).speakStep(
          'Read the current step.',
          previewProfile: systemProfile,
        );

    expect(sherpa.speakCalls, 0);
    expect(neural.speakCalls, 1);
    expect(platformTts.spokenTexts, <String>['Read the current step.']);
  });
}