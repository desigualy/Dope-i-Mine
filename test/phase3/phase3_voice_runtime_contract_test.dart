import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 3 voice runtime contract', () {
    test('voice runtime files remain present', () {
      for (final path in <String>[
        'lib/core/services/speech_to_text_service.dart',
        'lib/core/services/text_to_speech_service.dart',
        'lib/core/services/sherpa_onnx_text_to_speech_service.dart',
        'lib/presentation/voice/voice_io_controller.dart',
        'lib/presentation/voice/voice_input_button.dart',
        'lib/presentation/voice/speak_button.dart',
        'lib/presentation/voice/voice_test_panel.dart',
      ]) {
        expect(File(path).existsSync(), isTrue, reason: '$path should exist');
      }
    });

    test('voice settings expose STT and TTS diagnostics with stop controls',
        () {
      final panel = _read('lib/presentation/voice/voice_test_panel.dart');
      final settings =
          _read('lib/presentation/settings/voice_profile_screen.dart');

      expect(settings, contains('VoiceTestPanel'));
      expect(panel, contains('Text-to-Speech'));
      expect(panel, contains('Speech-to-Text'));
      expect(panel, contains('Stop Speaking'));
      expect(panel, contains('Stop Listening'));
      expect(panel, contains('cancelListening'));
      expect(panel, contains('recognizedText'));
      expect(panel, contains('errorMessage'));
    });

    test('task input and task steps keep voice controls wired', () {
      final taskInput = _read('lib/presentation/tasks/task_input_screen.dart');
      final stepCard = _read('lib/presentation/tasks/widgets/step_card.dart');

      expect(taskInput, contains('VoiceInputButton'));
      expect(stepCard, contains('SpeakButton'));
    });

    test('voice controller prefers Sherpa before fallback engines', () {
      final controller = _read('lib/presentation/voice/voice_controller.dart');

      expect(controller, contains('SherpaOnnxTextToSpeechService'));
      expect(controller.indexOf('_sherpaTts.speak'),
          lessThan(controller.indexOf('_neuralTts.speak')));
      expect(controller.indexOf('_neuralTts.speak'),
          lessThan(controller.indexOf('_tts.initialize')));
    });

    test('Android microphone permission remains present', () {
      final manifest = _read('android/app/src/main/AndroidManifest.xml');
      expect(manifest, contains('android.permission.RECORD_AUDIO'));
    });
  });
}

String _read(String path) => File(path).readAsStringSync();
