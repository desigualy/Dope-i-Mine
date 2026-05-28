import 'dart:io';
import 'dart:typed_data';

import 'package:dope_i_mine/core/services/neural_tts_service.dart';
import 'package:dope_i_mine/core/services/sherpa_onnx_text_to_speech_service.dart';
import 'package:dope_i_mine/domain/voice/offline_tts_voice_model.dart';
import 'package:dope_i_mine/domain/voice/voice_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeModelManager extends SherpaOnnxTtsModelManager {
  _FakeModelManager(this.model);

  final SherpaOnnxTtsModelPaths? model;

  @override
  Future<SherpaOnnxTtsModelPaths?> ensureModelAvailable([
    OfflineTtsVoiceModel? voice,
  ]) async =>
      model;
}

class _FakeEngineFactory extends SherpaOnnxOfflineTtsFactory {
  int createCalls = 0;
  final _FakeEngine engine = _FakeEngine();

  @override
  SherpaOnnxOfflineTtsEngine create(SherpaOnnxTtsModelPaths model) {
    createCalls += 1;
    return engine;
  }
}

class _FakeEngine implements SherpaOnnxOfflineTtsEngine {
  int generateCalls = 0;
  int freeCalls = 0;

  @override
  SherpaOnnxGeneratedAudio generate({
    required String text,
    required int speakerId,
    required double speed,
  }) {
    generateCalls += 1;
    return SherpaOnnxGeneratedAudio(
      samples: Float32List.fromList(<double>[0, 0.2, -0.2, 0.1]),
      sampleRate: 16000,
    );
  }

  @override
  void free() {
    freeCalls += 1;
  }
}

class _FakeAudioCache extends SherpaOnnxAudioCache {
  _FakeAudioCache(this.directory);

  final Directory directory;
  final Map<String, Uint8List> memoryCache = <String, Uint8List>{};

  @override
  Future<Directory> audioFileDirectory() async => directory;

  @override
  Future<Uint8List?> load(String cacheKey) async => memoryCache[cacheKey];

  @override
  Future<void> save({
    required String cacheKey,
    required Uint8List audioBytes,
  }) async {
    memoryCache[cacheKey] = audioBytes;
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
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('sherpa_tts_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  const profile = VoiceProfileModel(
    id: 'local-neural',
    provider: 'sherpa_onnx',
    label: 'Local Neural',
    localeId: 'en-GB',
    accent: 'UK',
    gender: 'female',
    pace: 'steady',
    warmth: 'high',
    firmness: 'low',
    tonePreset: 'calm',
  );

  const model = SherpaOnnxTtsModelPaths(
    id: 'test-model',
    model: 'model.onnx',
    tokens: 'tokens.txt',
    dataDir: 'espeak-ng-data',
    speakerId: 0,
  );

  test('generates local Sherpa speech, caches it, and reuses cache', () async {
    final factory = _FakeEngineFactory();
    final cache = _FakeAudioCache(tempDir);
    final player = _FakeCachedAudioPlayer();
    final service = SherpaOnnxTextToSpeechService(
      modelManager: _FakeModelManager(model),
      cache: cache,
      player: player,
      engineFactory: factory,
    );

    final generated = await service.speak(
      text: 'Take one small step.',
      profile: profile,
      speechRate: 0.8,
    );

    expect(generated, isTrue);
    expect(factory.createCalls, 1);
    expect(factory.engine.generateCalls, 1);
    expect(cache.memoryCache, hasLength(1));
    expect(player.playedPaths, hasLength(1));
    final wavBytes = File(player.playedPaths.single).readAsBytesSync();
    expect(wavBytes.take(4), equals('RIFF'.codeUnits));

    final cached = await service.speak(
      text: 'Take one small step.',
      profile: profile,
      speechRate: 0.8,
    );

    expect(cached, isTrue);
    expect(factory.createCalls, 1);
    expect(factory.engine.generateCalls, 1);
    expect(player.playedPaths, hasLength(2));
  });

  test('reports unavailable so the controller can fall back', () async {
    final service = SherpaOnnxTextToSpeechService(
      modelManager: _FakeModelManager(null),
      cache: _FakeAudioCache(tempDir),
      player: _FakeCachedAudioPlayer(),
      engineFactory: _FakeEngineFactory(),
    );

    final spoke = await service.speak(text: 'No local model yet.');

    expect(spoke, isFalse);
  });
}
