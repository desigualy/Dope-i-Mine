class InstalledTtsVoiceModel {
  const InstalledTtsVoiceModel({
    required this.name,
    required this.locale,
    this.networkConnectionRequired,
    this.notInstalled,
    this.quality,
    this.latency,
  });

  final String name;
  final String locale;
  final bool? networkConnectionRequired;
  final bool? notInstalled;
  final String? quality;
  final String? latency;

  String get id => '$locale::$name';

  String get displayLabel {
    final availability = notInstalled == true ? ' · not installed' : '';
    final network = networkConnectionRequired == true ? ' · network' : '';
    return '$name ($locale)$network$availability';
  }

  Map<String, String> get platformVoice => <String, String>{
        'name': name,
        'locale': locale,
      };

  factory InstalledTtsVoiceModel.fromPlatformMap(Map<dynamic, dynamic> voice) {
    return InstalledTtsVoiceModel(
      name: _stringValue(voice, 'name'),
      locale: _stringValue(voice, 'locale'),
      networkConnectionRequired:
          _boolValue(voice, 'networkConnectionRequired'),
      notInstalled: _boolValue(voice, 'notInstalled'),
      quality: _stringValueOrNull(voice, 'quality'),
      latency: _stringValueOrNull(voice, 'latency'),
    );
  }

  static String _stringValue(Map<dynamic, dynamic> voice, String key) {
    final value = voice[key];
    return value is String ? value : '';
  }

  static String? _stringValueOrNull(Map<dynamic, dynamic> voice, String key) {
    final value = voice[key];
    return value is String && value.isNotEmpty ? value : null;
  }

  static bool? _boolValue(Map<dynamic, dynamic> voice, String key) {
    final value = voice[key];
    return value is bool ? value : null;
  }
}