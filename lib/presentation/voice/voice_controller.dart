import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/speech_to_text_service.dart';
import '../../core/services/text_to_speech_service.dart';
import '../../providers.dart';

final voiceControllerProvider = Provider<VoiceController>((ref) {
  return VoiceController(
    ref.watch(speechToTextServiceProvider),
    ref.watch(textToSpeechServiceProvider),
  );
});

class VoiceController {
  VoiceController(this._stt, this._tts);

  final SpeechToTextService _stt;
  final TextToSpeechService _tts;

  Future<void> speakStep(String text) async {
    await _tts.initialize();
    await _tts.speak(text);
  }

  Future<void> listenForTask(void Function(String text) onResult) async {
    final ready = await _stt.initialize();
    if (!ready) return;
    await _stt.listen(onResult);
  }
}
