import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/avatar/avatar_generation_candidate.dart';
import '../../domain/avatar/avatar_variation_strength.dart';
import '../../domain/companion/avatar_config_model.dart';
import 'local_json_store.dart';

final localAvatarStoreProvider = Provider<LocalAvatarStore>((ref) {
  return LocalAvatarStore();
});

class LocalAvatarStore {
  LocalAvatarStore({LocalJsonStore? store})
      : _store = store ?? LocalJsonStore('dope_i_mine.local.avatar.v1');

  final LocalJsonStore _store;

  static const String _selectedKey = 'selected';
  static const String _candidateKey = 'fallback_candidates';
  static const String _avatarConfigKey = 'avatar_config';

  Future<void> saveAvatarConfig(AvatarConfigModel config) async {
    await _store.writeMap(_avatarConfigKey, <String, dynamic>{
      'avatarStyle': config.avatarStyle,
      'avatarPalette': config.avatarPalette,
      'accessoryConfig': config.accessoryConfig,
    });
  }

  Future<AvatarConfigModel?> loadAvatarConfig() async {
    final json = await _store.readMap(_avatarConfigKey);
    if (json == null) return null;

    final rawAccessoryConfig = json['accessoryConfig'];
    final accessoryConfig = rawAccessoryConfig is Map
        ? Map<String, dynamic>.from(rawAccessoryConfig)
        : <String, dynamic>{};

    return AvatarConfigModel(
      avatarStyle: (json['avatarStyle'] as String?) ??
          (json['avatar_style'] as String?) ??
          AvatarConfigModel.defaultAvatarMode,
      avatarPalette: (json['avatarPalette'] as String?) ??
          (json['avatar_palette'] as String?) ??
          AvatarConfigModel.defaultAvatarPalette,
      accessoryConfig: accessoryConfig,
    );
  }

  Future<void> clearAvatarConfig() async {
    await _store.remove(_avatarConfigKey);
  }

  Future<void> saveSelectedCandidate(AvatarGenerationCandidate candidate) async {
    await _store.writeMap(_selectedKey, candidate.toJson());
  }

  Future<AvatarGenerationCandidate?> loadSelectedCandidate() async {
    final json = await _store.readMap(_selectedKey);
    if (json == null) return null;
    return AvatarGenerationCandidate.fromJson(json);
  }

  Future<List<AvatarGenerationCandidate>> fallbackCandidates() async {
    final cached = await _store.readList(_candidateKey);
    if (cached.isNotEmpty) {
      return cached.map(AvatarGenerationCandidate.fromJson).toList();
    }

    final generated = <AvatarGenerationCandidate>[
      _candidate('calm_companion', 'Calm Companion', 0xFF7DD3FC),
      _candidate('focus_friend', 'Focus Friend', 0xFFA7F3D0),
      _candidate('cozy_helper', 'Cozy Helper', 0xFFFDE68A),
      _candidate('bright_starter', 'Bright Starter', 0xFFF0ABFC),
    ];
    await _store.writeList(
      _candidateKey,
      generated.map((candidate) => candidate.toJson()).toList(),
    );
    return generated;
  }

  AvatarGenerationCandidate _candidate(String id, String label, int color) {
    final hex = color.toRadixString(16).padLeft(8, '0').substring(2);
    final safeLabel = label
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');

    final svg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <rect width="512" height="512" rx="96" fill="#$hex"/>
  <circle cx="256" cy="210" r="82" fill="white" opacity="0.92"/>
  <path d="M154 384c14-58 56-94 102-94s88 36 102 94c7 29-16 54-46 54H200c-30 0-53-25-46-54z" fill="white" opacity="0.92"/>
  <circle cx="226" cy="205" r="10" fill="#1f2937" opacity="0.9"/>
  <circle cx="286" cy="205" r="10" fill="#1f2937" opacity="0.9"/>
  <path d="M226 247c18 18 42 18 60 0" stroke="#1f2937" stroke-width="10" stroke-linecap="round" fill="none" opacity="0.85"/>
  <text x="256" y="474" text-anchor="middle" font-family="Arial, sans-serif" font-size="32" font-weight="700" fill="#1f2937">$safeLabel</text>
</svg>
''';

    return AvatarGenerationCandidate(
      id: 'offline_$id',
      imageUrl: 'data:image/svg+xml;utf8,${Uri.encodeComponent(svg)}',
      qualityScore: 0.72,
      seed: 'offline_$id',
      variationStrength: AvatarVariationStrength.medium,
      providerId: 'offline_fallback',
      revisedPrompt: label,
      metadata: <String, dynamic>{
        'offline': true,
        'fallback': true,
        'label': label,
      },
    );
  }
}
