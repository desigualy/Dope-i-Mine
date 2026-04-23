import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextService {
  final SpeechToText _speech = SpeechToText();

  Future<bool> initialize() => _speech.initialize();

  Future<void> listen(void Function(String text) onResult) async {
    await _speech.listen(onResult: (result) => onResult(result.recognizedWords));
  }

  Future<void> stop() => _speech.stop();
}
