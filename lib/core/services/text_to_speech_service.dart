import 'package:flutter_tts/flutter_tts.dart';

import '../../domain/voice/installed_tts_voice_model.dart';
import '../../domain/voice/voice_profile_model.dart';

class TextToSpeechService {
  TextToSpeechService({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;

  Future<void> initialize({
    VoiceProfileModel? profile,
    double? speechRate,
    String? platformVoiceName,
    String? platformVoiceLocale,
  }) async {
    final localeId = platformVoiceLocale ?? profile?.localeId ?? 'en-GB';
    await _tts.setLanguage(localeId);
    await _tts.setSpeechRate(speechRate ?? profile?.defaultRate ?? 0.45);
    await _tts.setPitch(profile?.defaultPitch ?? 1.0);
    final selectedVoiceName = platformVoiceName ?? profile?.platformVoiceName;
    if (selectedVoiceName != null && selectedVoiceName.isNotEmpty) {
      await _trySetVoice(<String, String>{
        'name': selectedVoiceName,
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

  Future<List<InstalledTtsVoiceModel>> installedVoices() async {
    final rawVoices = await _safeGetVoices();
    if (rawVoices is! List) return const <InstalledTtsVoiceModel>[];

    final voices = rawVoices
        .whereType<Map>()
        .map(InstalledTtsVoiceModel.fromPlatformMap)
        .where((voice) => voice.name.isNotEmpty && voice.locale.isNotEmpty)
        .where((voice) => voice.notInstalled != true)
        .toList();
    voices.sort((a, b) {
      final locale = a.locale.compareTo(b.locale);
      return locale == 0 ? a.name.compareTo(b.name) : locale;
    });
    return voices;
  }

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
