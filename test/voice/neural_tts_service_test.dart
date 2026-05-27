import 'dart:typed_data';

import 'package:dope_i_mine/core/services/neural_tts_service.dart';
import 'package:dope_i_mine/domain/voice/voice_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeNeuralTtsClient implements NeuralTtsClient {
  _FakeNeuralTtsClient(this.audioBytes);

  final Uint8List? audioBytes;
  int generateCalls = 0;

  @override
  Future<Uint8List?> generate(NeuralTtsRequest request) async {
    generateCalls += 1;
    return audioBytes;
  }
}

class _FakeCachedAudioPlayer implements CachedAudioPlayer {
  final List<String> playedPaths = <String>[];
  int stopCalls = 0;

  @override
  Future<void> playFile(String path) async {
    playedPaths.add(path);
  }

  @override
  Future<void> stop() async {
    stopCalls += 1;
  }
}

void main() {
  const profile = VoiceProfileModel(
    id: 'calm',
    provider: 'neural',
    label: 'Calm Guide',
    localeId: 'en-GB',
    accent: 'UK',
    gender: 'female',
    pace: 'slow',
    warmth: 'high',
    firmness: 'low',
    tonePreset: 'calm',
  );

  test('generated neural speech is cached and reused offline', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final firstClient =
        _FakeNeuralTtsClient(Uint8List.fromList(<int>[1, 2, 3]));
    final firstPlayer = _FakeCachedAudioPlayer();
    final firstService = NeuralTtsService(
      client: firstClient,
      cache: NeuralTtsAudioCache(preferences: prefs),
      player: firstPlayer,
    );

    final generated = await firstService.speak(
      text: 'Take one small step.',
      profile: profile,
      speechRate: 0.8,
    );

    expect(generated, isTrue);
    expect(firstClient.generateCalls, 1);
    expect(firstPlayer.playedPaths, hasLength(1));

    final offlineClient = _FakeNeuralTtsClient(null);
    final offlinePlayer = _FakeCachedAudioPlayer();
    final offlineService = NeuralTtsService(
      client: offlineClient,
      cache: NeuralTtsAudioCache(preferences: prefs),
      player: offlinePlayer,
    );

    final cached = await offlineService.speak(
      text: 'Take one small step.',
      profile: profile,
      speechRate: 0.8,
    );

    expect(cached, isTrue);
    expect(offlineClient.generateCalls, 0);
    expect(offlinePlayer.playedPaths, hasLength(1));
  });

  test('neural speech reports unavailable when not cached or generated',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final service = NeuralTtsService(
      client: _FakeNeuralTtsClient(null),
      cache: NeuralTtsAudioCache(
        preferences: await SharedPreferences.getInstance(),
      ),
      player: _FakeCachedAudioPlayer(),
    );

    final spoke = await service.speak(
      text: 'Uncached phrase.',
      profile: profile,
      speechRate: 0.8,
    );

    expect(spoke, isFalse);
  });
}
