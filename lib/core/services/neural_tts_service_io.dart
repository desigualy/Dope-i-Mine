import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/voice/voice_profile_model.dart';

class NeuralTtsService {
  NeuralTtsService({
    required NeuralTtsClient client,
    required NeuralTtsAudioCache cache,
    required CachedAudioPlayer player,
  })  : _client = client,
        _cache = cache,
        _player = player;

  final NeuralTtsClient _client;
  final NeuralTtsAudioCache _cache;
  final CachedAudioPlayer _player;

  Future<bool> speak({
    required String text,
    VoiceProfileModel? profile,
    double? speechRate,
  }) async {
    final request = NeuralTtsRequest(
      text: text,
      voiceProfileId: profile?.id,
      localeId: profile?.localeId ?? 'en-GB',
      tonePreset: profile?.tonePreset,
      speechRate: speechRate ?? profile?.defaultRate ?? 1.0,
    );
    final cacheKey = request.cacheKey;
    final cached = await _cache.load(cacheKey);
    if (cached != null) {
      await _playBytes(cacheKey: cacheKey, audioBytes: cached);
      return true;
    }

    final generated = await _client.generate(request);
    if (generated == null || generated.isEmpty) return false;

    await _cache.save(cacheKey: cacheKey, audioBytes: generated);
    await _playBytes(cacheKey: cacheKey, audioBytes: generated);
    return true;
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> _playBytes({
    required String cacheKey,
    required Uint8List audioBytes,
  }) async {
    final directory = Directory('${Directory.systemTemp.path}/dope_i_mine_tts');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    final file = File('${directory.path}/$cacheKey.mp3');
    await file.writeAsBytes(audioBytes, flush: true);
    await _player.playFile(file.path);
  }
}

class NeuralTtsRequest {
  const NeuralTtsRequest({
    required this.text,
    required this.voiceProfileId,
    required this.localeId,
    required this.tonePreset,
    required this.speechRate,
  });

  final String text;
  final String? voiceProfileId;
  final String localeId;
  final String? tonePreset;
  final double speechRate;

  String get cacheKey {
    final normalized = jsonEncode(<String, Object?>{
      'text': text.trim(),
      'voiceProfileId': voiceProfileId,
      'localeId': localeId,
      'tonePreset': tonePreset,
      'speechRate': speechRate.toStringAsFixed(2),
    });
    return _fnv1a32(normalized).toRadixString(16);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'text': text,
      'voiceProfileId': voiceProfileId,
      'localeId': localeId,
      'tonePreset': tonePreset,
      'speechRate': speechRate,
      'format': 'mp3',
    };
  }

  static int _fnv1a32(String input) {
    var hash = 0x811c9dc5;
    for (final codeUnit in input.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash;
  }
}

abstract class NeuralTtsClient {
  Future<Uint8List?> generate(NeuralTtsRequest request);
}

class HttpNeuralTtsClient implements NeuralTtsClient {
  HttpNeuralTtsClient({
    http.Client? client,
    String? endpoint,
    String? apiKey,
  })  : _client = client ?? http.Client(),
        _endpoint = endpoint ?? _defaultEndpoint,
        _apiKey = apiKey ?? _defaultApiKey;

  static const String _defaultEndpoint = String.fromEnvironment(
    'NEURAL_TTS_ENDPOINT',
  );
  static const String _defaultApiKey = String.fromEnvironment(
    'NEURAL_TTS_API_KEY',
  );

  final http.Client _client;
  final String _endpoint;
  final String _apiKey;

  bool get isConfigured => _endpoint.trim().isNotEmpty;

  @override
  Future<Uint8List?> generate(NeuralTtsRequest request) async {
    if (!isConfigured) return null;

    try {
      final response = await _client.post(
        Uri.parse(_endpoint),
        headers: <String, String>{
          'content-type': 'application/json',
          if (_apiKey.isNotEmpty) 'authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(request.toJson()),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final contentType = response.headers['content-type'] ?? '';
      if (contentType.contains('application/json')) {
        final decoded =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final encoded = decoded['audioBase64'] as String? ??
            decoded['audio_base64'] as String?;
        if (encoded == null || encoded.isEmpty) return null;
        return base64Decode(encoded);
      }
      return response.bodyBytes;
    } catch (_) {
      return null;
    }
  }
}

class NeuralTtsAudioCache {
  NeuralTtsAudioCache({SharedPreferences? preferences})
      : _preferences = preferences;

  static const String _prefix = 'voice.neural_tts.audio.';

  final SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async {
    final injected = _preferences;
    if (injected != null) return injected;
    return SharedPreferences.getInstance();
  }

  Future<Uint8List?> load(String cacheKey) async {
    final raw = (await _prefs).getString('$_prefix$cacheKey');
    if (raw == null || raw.isEmpty) return null;

    try {
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> save({
    required String cacheKey,
    required Uint8List audioBytes,
  }) async {
    await (await _prefs)
        .setString('$_prefix$cacheKey', base64Encode(audioBytes));
  }
}

abstract class CachedAudioPlayer {
  Future<void> playFile(String path);
  Future<void> stop();
}

class MethodChannelCachedAudioPlayer implements CachedAudioPlayer {
  const MethodChannelCachedAudioPlayer();

  static const MethodChannel _channel =
      MethodChannel('dope_i_mine/cached_audio');

  @override
  Future<void> playFile(String path) async {
    await _channel.invokeMethod<void>('playFile', <String, String>{
      'path': path,
    });
  }

  @override
  Future<void> stop() async {
    await _channel.invokeMethod<void>('stop');
  }
}
