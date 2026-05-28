import 'package:dope_i_mine/core/services/text_to_speech_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('flutter_tts');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'getVoices') {
        return <Map<String, Object?>>[
          <String, Object?>{
            'name': 'en-gb-x-gba-local',
            'locale': 'en-GB',
            'networkConnectionRequired': false,
            'notInstalled': false,
          },
          <String, Object?>{
            'name': 'en-us-x-sfg-network',
            'locale': 'en-US',
            'networkConnectionRequired': true,
            'notInstalled': false,
          },
        ];
      }
      return 1;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('discovers installed platform voices from flutter_tts', () async {
    final service = TextToSpeechService();

    final voices = await service.installedVoices();

    expect(voices.map((voice) => voice.name), <String>[
      'en-gb-x-gba-local',
      'en-us-x-sfg-network',
    ]);
    expect(voices.first.locale, 'en-GB');
  });

  test('voice selection maps installed voice name and locale into setVoice',
      () async {
    final service = TextToSpeechService();

    await service.initialize(
      platformVoiceName: 'en-us-x-sfg-network',
      platformVoiceLocale: 'en-US',
      speechRate: 0.9,
    );

    final setVoiceCall = calls.singleWhere((call) => call.method == 'setVoice');
    expect(
      setVoiceCall.arguments,
      <String, String>{
        'name': 'en-us-x-sfg-network',
        'locale': 'en-US',
      },
    );
  });
}