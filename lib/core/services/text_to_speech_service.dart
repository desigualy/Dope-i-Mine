import 'package:flutter_tts/flutter_tts.dart';

import '../../domain/voice/voice_profile_model.dart';

class TextToSpeechService {
  final FlutterTts _tts = FlutterTts();

  Future<void> initialize({
    VoiceProfileModel? profile,
    double? speechRate,
  }) async {
    final localeId = profile?.localeId ?? 'en-GB';
    await _tts.setLanguage(localeId);
    await _tts.setSpeechRate(speechRate ?? profile?.defaultRate ?? 0.45);
    await _tts.setPitch(profile?.defaultPitch ?? 1.0);
    final platformVoiceName = profile?.platformVoiceName;
    if (platformVoiceName != null && platformVoiceName.isNotEmpty) {
      await _tts.setVoice(<String, String>{
        'name': platformVoiceName,
        'locale': localeId,
      });
    }
  }

  Future<void> speak(String text) => _tts.speak(text);
  Future<void> stop() => _tts.stop();
}
