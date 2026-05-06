import 'avatar_engine_mode.dart';
import 'avatar_v4_rive_contract.dart';

class AvatarV4Config {
  const AvatarV4Config({
    this.engineMode = AvatarEngineMode.rivePrimary,
    this.rigAssetPath = AvatarV4RiveContract.baseRigAssetPath,
    this.artboardName = AvatarV4RiveContract.artboardName,
    this.stateMachineName = AvatarV4RiveContract.stateMachineName,
    this.skinTone = 'tan_warm',
    this.faceShape = 'soft_oval',
    this.hairPackId = 'hair_ringlet_afro_v1',
    this.hairStyleId = 'long_copper_ringlet_afro',
    this.hairColor = 'copper_brown',
    this.eyeShape = 'soft_almond',
    this.eyeColor = 'brown',
    this.freckles = true,
    this.vitiligo = false,
    this.birthmarkIds = const <String>[],
    this.scarIds = const <String>[],
    this.matureLineIds = const <String>[],
    this.facialHairStyleId = 'none',
    this.bodyPresetId = 'average_soft',
    this.topId = 'starter_black_top',
    this.bottomId = 'starter_jeans',
    this.shoeId = 'starter_trainers',
    this.accessoryIds = const <String>[],
    this.ownedItemIds = const <String>[],
    this.updatedAtIso,
  });

  static const String defaultBaseRigAssetPath = AvatarV4RiveContract.baseRigAssetPath;
  static const String defaultArtboardName = AvatarV4RiveContract.artboardName;
  static const String defaultStateMachineName = AvatarV4RiveContract.stateMachineName;

  final AvatarEngineMode engineMode;
  final String rigAssetPath;
  final String artboardName;
  final String stateMachineName;

  final String skinTone;
  final String faceShape;
  final String hairPackId;
  final String hairStyleId;
  final String hairColor;
  final String eyeShape;
  final String eyeColor;

  final bool freckles;
  final bool vitiligo;
  final List<String> birthmarkIds;
  final List<String> scarIds;
  final List<String> matureLineIds;

  final String facialHairStyleId;
  final String bodyPresetId;
  final String topId;
  final String bottomId;
  final String shoeId;
  final List<String> accessoryIds;
  final List<String> ownedItemIds;
  final String? updatedAtIso;

  static AvatarV4Config starter() {
    return AvatarV4Config(
      updatedAtIso: DateTime.now().toUtc().toIso8601String(),
    );
  }

  AvatarV4Config copyWith({
    AvatarEngineMode? engineMode,
    String? rigAssetPath,
    String? artboardName,
    String? stateMachineName,
    String? skinTone,
    String? faceShape,
    String? hairPackId,
    String? hairStyleId,
    String? hairColor,
    String? eyeShape,
    String? eyeColor,
    bool? freckles,
    bool? vitiligo,
    List<String>? birthmarkIds,
    List<String>? scarIds,
    List<String>? matureLineIds,
    String? facialHairStyleId,
    String? bodyPresetId,
    String? topId,
    String? bottomId,
    String? shoeId,
    List<String>? accessoryIds,
    List<String>? ownedItemIds,
    String? updatedAtIso,
  }) {
    return AvatarV4Config(
      engineMode: engineMode ?? this.engineMode,
      rigAssetPath: rigAssetPath ?? this.rigAssetPath,
      artboardName: artboardName ?? this.artboardName,
      stateMachineName: stateMachineName ?? this.stateMachineName,
      skinTone: skinTone ?? this.skinTone,
      faceShape: faceShape ?? this.faceShape,
      hairPackId: hairPackId ?? this.hairPackId,
      hairStyleId: hairStyleId ?? this.hairStyleId,
      hairColor: hairColor ?? this.hairColor,
      eyeShape: eyeShape ?? this.eyeShape,
      eyeColor: eyeColor ?? this.eyeColor,
      freckles: freckles ?? this.freckles,
      vitiligo: vitiligo ?? this.vitiligo,
      birthmarkIds: birthmarkIds ?? this.birthmarkIds,
      scarIds: scarIds ?? this.scarIds,
      matureLineIds: matureLineIds ?? this.matureLineIds,
      facialHairStyleId: facialHairStyleId ?? this.facialHairStyleId,
      bodyPresetId: bodyPresetId ?? this.bodyPresetId,
      topId: topId ?? this.topId,
      bottomId: bottomId ?? this.bottomId,
      shoeId: shoeId ?? this.shoeId,
      accessoryIds: accessoryIds ?? this.accessoryIds,
      ownedItemIds: ownedItemIds ?? this.ownedItemIds,
      updatedAtIso: updatedAtIso ?? this.updatedAtIso,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'engineMode': engineMode.name,
      'rigAssetPath': rigAssetPath,
      'artboardName': artboardName,
      'stateMachineName': stateMachineName,
      'skinTone': skinTone,
      'faceShape': faceShape,
      'hairPackId': hairPackId,
      'hairStyleId': hairStyleId,
      'hairColor': hairColor,
      'eyeShape': eyeShape,
      'eyeColor': eyeColor,
      'freckles': freckles,
      'vitiligo': vitiligo,
      'birthmarkIds': birthmarkIds,
      'scarIds': scarIds,
      'matureLineIds': matureLineIds,
      'facialHairStyleId': facialHairStyleId,
      'bodyPresetId': bodyPresetId,
      'topId': topId,
      'bottomId': bottomId,
      'shoeId': shoeId,
      'accessoryIds': accessoryIds,
      'ownedItemIds': ownedItemIds,
      'updatedAtIso': updatedAtIso,
    };
  }

  static AvatarV4Config fromJson(Map<String, dynamic> json) {
    return AvatarV4Config(
      engineMode: _mode(json['engineMode']),
      rigAssetPath: _string(json['rigAssetPath'], defaultBaseRigAssetPath),
      artboardName: _string(json['artboardName'], defaultArtboardName),
      stateMachineName: _string(json['stateMachineName'], defaultStateMachineName),
      skinTone: _string(json['skinTone'], 'tan_warm'),
      faceShape: _string(json['faceShape'], 'soft_oval'),
      hairPackId: _string(json['hairPackId'], 'hair_ringlet_afro_v1'),
      hairStyleId: _string(json['hairStyleId'], 'long_copper_ringlet_afro'),
      hairColor: _string(json['hairColor'], 'copper_brown'),
      eyeShape: _string(json['eyeShape'], 'soft_almond'),
      eyeColor: _string(json['eyeColor'], 'brown'),
      freckles: json['freckles'] == true,
      vitiligo: json['vitiligo'] == true,
      birthmarkIds: _stringList(json['birthmarkIds']),
      scarIds: _stringList(json['scarIds']),
      matureLineIds: _stringList(json['matureLineIds']),
      facialHairStyleId: _string(json['facialHairStyleId'], 'none'),
      bodyPresetId: _string(json['bodyPresetId'], 'average_soft'),
      topId: _string(json['topId'], 'starter_black_top'),
      bottomId: _string(json['bottomId'], 'starter_jeans'),
      shoeId: _string(json['shoeId'], 'starter_trainers'),
      accessoryIds: _stringList(json['accessoryIds']),
      ownedItemIds: _stringList(json['ownedItemIds']),
      updatedAtIso: json['updatedAtIso'] is String ? json['updatedAtIso'] as String : null,
    );
  }

  static AvatarEngineMode _mode(Object? value) {
    if (value is String) {
      for (final mode in AvatarEngineMode.values) {
        if (mode.name == value) return mode;
      }
    }
    return AvatarEngineMode.rivePrimary;
  }

  static String _string(Object? value, String fallback) {
    return value is String && value.trim().isNotEmpty ? value : fallback;
  }

  static List<String> _stringList(Object? value) {
    if (value is Iterable) {
      return value
          .whereType<String>()
          .where((item) => item.trim().isNotEmpty)
          .toList(growable: false);
    }
    return const <String>[];
  }
}
