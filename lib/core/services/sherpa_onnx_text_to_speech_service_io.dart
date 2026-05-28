import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

import '../../domain/voice/offline_tts_voice_model.dart';
import '../../domain/voice/voice_profile_model.dart';
import 'neural_tts_service.dart';

class SherpaOnnxTextToSpeechService {
  SherpaOnnxTextToSpeechService({
    required SherpaOnnxTtsModelManager modelManager,
    required SherpaOnnxAudioCache cache,
    required CachedAudioPlayer player,
    SherpaOnnxOfflineTtsFactory? engineFactory,
  })  : _modelManager = modelManager,
        _cache = cache,
        _player = player,
        _engineFactory = engineFactory ?? SherpaOnnxOfflineTtsFactory();

  final SherpaOnnxTtsModelManager _modelManager;
  final SherpaOnnxAudioCache _cache;
  final CachedAudioPlayer _player;
  final SherpaOnnxOfflineTtsFactory _engineFactory;

  SherpaOnnxOfflineTtsEngine? _engine;
  SherpaOnnxTtsModelPaths? _loadedModel;

  Future<bool> speak({
    required String text,
    VoiceProfileModel? profile,
    double? speechRate,
    OfflineTtsVoiceModel? offlineVoice,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return true;

    final selectedVoice = offlineVoice ??
        OfflineTtsVoiceModel.byId(profile?.offlineVoiceId) ??
        OfflineTtsVoiceModel.defaultVoice();
    final model = await _modelManager.ensureModelAvailable(selectedVoice);
    if (model == null) return false;

    final speed = _speedFromSpeechRate(speechRate ?? profile?.defaultRate);
    final cacheKey = _cacheKey(
      text: trimmed,
      modelId: model.id,
      speed: speed,
      speakerId: model.speakerId,
      offlineVoiceId: selectedVoice.id,
    );
    final cached = await _cache.load(cacheKey);
    if (cached != null) {
      await _playBytes(cacheKey: cacheKey, audioBytes: cached);
      return true;
    }

    final engine = _engineFor(model);
    final generated = engine.generate(
      text: trimmed,
      speakerId: model.speakerId,
      speed: speed,
    );
    if (generated.samples.isEmpty || generated.sampleRate <= 0) return false;

    final wavBytes = _wavFromFloatSamples(
      generated.samples,
      sampleRate: generated.sampleRate,
    );
    await _cache.save(cacheKey: cacheKey, audioBytes: wavBytes);
    await _playBytes(cacheKey: cacheKey, audioBytes: wavBytes);
    return true;
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<OfflineTtsVoiceDownloadStatus> downloadStatus(
    OfflineTtsVoiceModel voice,
  ) {
    return _modelManager.downloadStatus(voice);
  }

  SherpaOnnxOfflineTtsEngine _engineFor(SherpaOnnxTtsModelPaths model) {
    final current = _engine;
    if (current != null && _loadedModel?.id == model.id) return current;

    current?.free();
    _loadedModel = model;
    _engine = _engineFactory.create(model);
    return _engine!;
  }

  Future<void> _playBytes({
    required String cacheKey,
    required Uint8List audioBytes,
  }) async {
    final directory = await _cache.audioFileDirectory();
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    final file = File('${directory.path}/$cacheKey.wav');
    await file.writeAsBytes(audioBytes, flush: true);
    await _player.playFile(file.path);
  }

  double _speedFromSpeechRate(double? speechRate) {
    final rate = speechRate ?? 1.0;
    if (rate <= 0) return 1.0;
    return rate.clamp(0.7, 1.25).toDouble();
  }

  String _cacheKey({
    required String text,
    required String modelId,
    required double speed,
    required int speakerId,
    required String offlineVoiceId,
  }) {
    final encoded = jsonEncode(<String, Object?>{
      'engine': 'sherpa_onnx',
      'offlineVoiceId': offlineVoiceId,
      'modelId': modelId,
      'speakerId': speakerId,
      'speed': speed.toStringAsFixed(2),
      'text': text,
    });
    return _fnv1a32(encoded).toRadixString(16);
  }

  int _fnv1a32(String input) {
    var hash = 0x811c9dc5;
    for (final codeUnit in input.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash;
  }

  Uint8List _wavFromFloatSamples(
    Float32List samples, {
    required int sampleRate,
  }) {
    const channels = 1;
    const bitsPerSample = 16;
    final dataSize = samples.length * 2;
    final bytes = BytesBuilder();

    void writeString(String value) => bytes.add(ascii.encode(value));
    void writeUint16(int value) {
      bytes.add(<int>[value & 0xff, (value >> 8) & 0xff]);
    }

    void writeUint32(int value) {
      bytes.add(<int>[
        value & 0xff,
        (value >> 8) & 0xff,
        (value >> 16) & 0xff,
        (value >> 24) & 0xff,
      ]);
    }

    writeString('RIFF');
    writeUint32(36 + dataSize);
    writeString('WAVE');
    writeString('fmt ');
    writeUint32(16);
    writeUint16(1);
    writeUint16(channels);
    writeUint32(sampleRate);
    writeUint32(sampleRate * channels * bitsPerSample ~/ 8);
    writeUint16(channels * bitsPerSample ~/ 8);
    writeUint16(bitsPerSample);
    writeString('data');
    writeUint32(dataSize);

    for (final sample in samples) {
      final scaled =
          (sample.clamp(-1.0, 1.0) * 32767).round().clamp(-32768, 32767);
      final value = scaled < 0 ? scaled + 65536 : scaled;
      writeUint16(value);
    }

    return bytes.toBytes();
  }
}

class SherpaOnnxTtsModelManager {
  SherpaOnnxTtsModelManager({
    http.Client? client,
    String? modelArchiveUrl,
  })  : _client = client ?? http.Client(),
        _modelArchiveUrlOverride = modelArchiveUrl;

  final http.Client _client;
  final String? _modelArchiveUrlOverride;

  Future<SherpaOnnxTtsModelPaths?> ensureModelAvailable([
    OfflineTtsVoiceModel? voice,
  ]) async {
    final selectedVoice = voice ?? OfflineTtsVoiceModel.defaultVoice();
    final root = await _modelRoot();
    final paths = _pathsFor(root, selectedVoice);
    if (paths.existsSync()) return paths;

    final archiveUrl = _modelArchiveUrlOverride ?? selectedVoice.modelArchiveUrl;
    if (archiveUrl.trim().isEmpty) return null;

    try {
      final response = await _client.get(Uri.parse(archiveUrl));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      await _extractTarBz2(response.bodyBytes, root);
      final extracted = _pathsFor(root, selectedVoice);
      return extracted.existsSync() ? extracted : null;
    } catch (_) {
      return null;
    }
  }

  Future<Directory> _modelRoot() async {
    final support = await getApplicationSupportDirectory();
    return Directory('${support.path}/sherpa_onnx_tts');
  }

  Future<OfflineTtsVoiceDownloadStatus> downloadStatus(
    OfflineTtsVoiceModel voice,
  ) async {
    final root = await _modelRoot();
    if (_pathsFor(root, voice).existsSync()) {
      return OfflineTtsVoiceDownloadStatus.ready;
    }
    return voice.canDownload
        ? OfflineTtsVoiceDownloadStatus.notDownloaded
        : OfflineTtsVoiceDownloadStatus.failed;
  }

  SherpaOnnxTtsModelPaths pathsForTesting(
    Directory root,
    OfflineTtsVoiceModel voice,
  ) {
    return _pathsFor(root, voice);
  }

  SherpaOnnxTtsModelPaths _pathsFor(
    Directory root,
    OfflineTtsVoiceModel voice,
  ) {
    final modelDir = Directory('${root.path}/${voice.modelDirectoryName}');
    return SherpaOnnxTtsModelPaths(
      id: voice.modelId,
      model: '${modelDir.path}/${voice.modelFileName}',
      tokens: '${modelDir.path}/${voice.tokensFileName}',
      dataDir: '${modelDir.path}/${voice.dataDirectoryName}',
      speakerId: voice.speakerId,
    );
  }

  Future<void> _extractTarBz2(Uint8List archiveBytes, Directory target) async {
    if (!target.existsSync()) target.createSync(recursive: true);

    final tarBytes = BZip2Decoder().decodeBytes(archiveBytes);
    final archive = TarDecoder().decodeBytes(tarBytes);
    for (final file in archive.files) {
      if (!file.isFile) continue;
      final output = _safeOutputFile(target, file.name);
      if (output == null) continue;
      output.parent.createSync(recursive: true);
      await output.writeAsBytes(file.content as List<int>, flush: true);
    }
  }

  File? _safeOutputFile(Directory target, String archivePath) {
    final normalized = archivePath.replaceAll('\\', '/');
    if (normalized.startsWith('/') || normalized.contains('../')) return null;
    return File('${target.path}/$normalized');
  }
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

  bool existsSync() {
    return File(model).existsSync() &&
        File(tokens).existsSync() &&
        Directory(dataDir).existsSync();
  }
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
    sherpa.initBindings();
    final tts = sherpa.OfflineTts(
      sherpa.OfflineTtsConfig(
        model: sherpa.OfflineTtsModelConfig(
          vits: sherpa.OfflineTtsVitsModelConfig(
            model: model.model,
            tokens: model.tokens,
            dataDir: model.dataDir,
          ),
          numThreads: math.max(1, Platform.numberOfProcessors ~/ 2),
        ),
      ),
    );
    return _SherpaOnnxOfflineTtsEngine(tts);
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

class _SherpaOnnxOfflineTtsEngine implements SherpaOnnxOfflineTtsEngine {
  _SherpaOnnxOfflineTtsEngine(this._tts);

  final sherpa.OfflineTts _tts;

  @override
  SherpaOnnxGeneratedAudio generate({
    required String text,
    required int speakerId,
    required double speed,
  }) {
    final audio = _tts.generate(text: text, sid: speakerId, speed: speed);
    return SherpaOnnxGeneratedAudio(
      samples: audio.samples,
      sampleRate: audio.sampleRate,
    );
  }

  @override
  void free() {
    _tts.free();
  }
}

class SherpaOnnxAudioCache {
  Future<Directory> audioFileDirectory() async {
    final support = await getApplicationSupportDirectory();
    return Directory('${support.path}/sherpa_onnx_tts_audio');
  }

  Future<Uint8List?> load(String cacheKey) async {
    final file = File('${(await audioFileDirectory()).path}/$cacheKey.wav');
    if (!file.existsSync()) return null;
    return file.readAsBytes();
  }

  Future<void> save({
    required String cacheKey,
    required Uint8List audioBytes,
  }) async {
    final directory = await audioFileDirectory();
    if (!directory.existsSync()) directory.createSync(recursive: true);
    await File('${directory.path}/$cacheKey.wav').writeAsBytes(
      audioBytes,
      flush: true,
    );
  }
}
