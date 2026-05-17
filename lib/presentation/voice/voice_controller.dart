import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/speech_to_text_service.dart';
import '../../core/services/text_to_speech_service.dart';
import '../../domain/voice/voice_profile_model.dart';
import '../../domain/voice/voice_settings_model.dart';
import '../../providers.dart';

final voiceControllerProvider = Provider<VoiceController>((ref) {
  return VoiceController(
    ref,
    ref.watch(speechToTextServiceProvider),
    ref.watch(textToSpeechServiceProvider),
  );
});

class VoiceController {
  VoiceController(this._ref, this._stt, this._tts);

  final Ref _ref;
  final SpeechToTextService _stt;
  final TextToSpeechService _tts;

  Future<void> speakStep(String text) async {
    final resolved = await _resolveVoice();
    await _tts.initialize(
      profile: resolved.profile,
      speechRate: resolved.settings?.speechRate,
    );
    await _tts.speak(text);
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
