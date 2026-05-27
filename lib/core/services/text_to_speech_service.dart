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
      await _trySetVoice(<String, String>{
        'name': platformVoiceName,
        'locale': localeId,
      });
    } else if (profile != null) {
      final inferredVoice = await _findInstalledVoice(profile);
      if (inferredVoice != null) {
        await _trySetVoice(inferredVoice);
      }
    }
  }

  Future<void> speak(String text) => _tts.speak(text);
  Future<void> stop() => _tts.stop();

  Future<Map<String, String>?> _findInstalledVoice(
      VoiceProfileModel profile) async {
    final voices = await _safeGetVoices();
    if (voices is! List) return null;

    final normalizedLocale = profile.localeId.toLowerCase();
    final genderHints = _genderHints(profile.gender);
    final localeMatches = voices
        .whereType<Map>()
        .map((voice) => Map<String, dynamic>.from(voice))
        .where((voice) {
      final locale = _stringValue(voice, 'locale').toLowerCase();
      return locale == normalizedLocale ||
          locale.replaceAll('_', '-') == normalizedLocale;
    }).toList();

    Map<String, dynamic>? selected;
    for (final voice in localeMatches) {
      final name = _stringValue(voice, 'name').toLowerCase();
      if (genderHints.any(name.contains)) {
        selected = voice;
        break;
      }
    }
    selected ??= localeMatches.isNotEmpty ? localeMatches.first : null;
    if (selected == null) return null;

    final name = _stringValue(selected, 'name');
    final locale = _stringValue(selected, 'locale');
    if (name.isEmpty || locale.isEmpty) return null;
    return <String, String>{'name': name, 'locale': locale};
  }

  Future<dynamic> _safeGetVoices() async {
    try {
      return await _tts.getVoices;
    } catch (_) {
      return null;
    }
  }

  Future<void> _trySetVoice(Map<String, String> voice) async {
    try {
      await _tts.setVoice(voice);
    } catch (_) {
      // Platform TTS voice identifiers vary by device. Keep speech usable even
      // when a saved or inferred voice is unavailable on this installation.
    }
  }

  List<String> _genderHints(String gender) {
    return switch (gender.toLowerCase()) {
      'female' => const <String>[
          'female',
          'woman',
          'samantha',
          'susan',
          'zira',
          'sonia',
          'hazel',
          'libby',
        ],
      'male' => const <String>[
          'male',
          'man',
          'daniel',
          'david',
          'mark',
          'george',
          'ryan',
          'james',
        ],
      _ => const <String>[],
    };
  }

  String _stringValue(Map<String, dynamic> voice, String key) {
    final value = voice[key];
    return value is String ? value : '';
  }
}
