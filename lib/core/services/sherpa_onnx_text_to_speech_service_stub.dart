import 'dart:typed_data';

import '../../domain/voice/voice_profile_model.dart';
import 'neural_tts_service.dart';

class SherpaOnnxTextToSpeechService {
  SherpaOnnxTextToSpeechService({
    required SherpaOnnxTtsModelManager modelManager,
    required SherpaOnnxAudioCache cache,
    required CachedAudioPlayer player,
    SherpaOnnxOfflineTtsFactory? engineFactory,
  }) : _player = player;

  final CachedAudioPlayer _player;

  Future<bool> speak({
    required String text,
    VoiceProfileModel? profile,
    double? speechRate,
  }) async {
    return false;
  }

  Future<void> stop() async {
    await _player.stop();
  }
}

class SherpaOnnxTtsModelManager {
  SherpaOnnxTtsModelManager({
    Object? client,
    String? modelArchiveUrl,
  });

  Future<SherpaOnnxTtsModelPaths?> ensureModelAvailable() async => null;
}

class SherpaOnnxTtsModelPaths {
  const SherpaOnnxTtsModelPaths({
    required this.id,
    required this.model,
    required this.tokens,
    required this.dataDir,
    required this.speakerId,
  });

  final String id;
  final String model;
  final String tokens;
  final String dataDir;
  final int speakerId;

  bool existsSync() => false;
}

class SherpaOnnxGeneratedAudio {
  const SherpaOnnxGeneratedAudio({
    required this.samples,
    required this.sampleRate,
  });

  final Float32List samples;
  final int sampleRate;
}

class SherpaOnnxOfflineTtsFactory {
  SherpaOnnxOfflineTtsEngine create(SherpaOnnxTtsModelPaths model) {
    return const _UnavailableSherpaOnnxOfflineTtsEngine();
  }
}

abstract class SherpaOnnxOfflineTtsEngine {
  SherpaOnnxGeneratedAudio generate({
    required String text,
    required int speakerId,
    required double speed,
  });

  void free();
}

class _UnavailableSherpaOnnxOfflineTtsEngine
    implements SherpaOnnxOfflineTtsEngine {
  const _UnavailableSherpaOnnxOfflineTtsEngine();

  @override
  SherpaOnnxGeneratedAudio generate({
    required String text,
    required int speakerId,
    required double speed,
  }) {
    return SherpaOnnxGeneratedAudio(
      samples: Float32List(0),
      sampleRate: 0,
    );
  }

  @override
  void free() {}
}

class SherpaOnnxAudioCache {
  Future<Object> audioFileDirectory() async => Object();

  Future<Uint8List?> load(String cacheKey) async => null;

  Future<void> save({
    required String cacheKey,
    required Uint8List audioBytes,
  }) async {}
}
