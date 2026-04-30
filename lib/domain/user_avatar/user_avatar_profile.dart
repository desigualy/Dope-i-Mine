class UserAvatarProfile {
  const UserAvatarProfile({
    this.avatarType = UserAvatarProfile.avatarTypeInspiredByMe,
    this.agePresentation = 'adult',
    this.skinTone = 'medium',
    this.faceShape = 'soft_round',
    this.hairType = 'wavy',
    this.hairStyle = 'short',
    this.hairColor = 'brown',
    this.bodyShape = 'average',
    this.accessibilityItems = const <String>[],
    this.clothingItems = const <String>['hoodie'],
    this.culturalItems = const <String>[],
    this.moodStyle = 'calm',
    this.backgroundColor = 'soft_teal',
    this.pronouns,
    this.displayName,
    this.avatarName,
    this.stylePreference = 'soft_illustrated',
  });

  const UserAvatarProfile.privateAbstract({
    this.moodStyle = 'calm',
    this.backgroundColor = 'soft_teal',
    this.pronouns,
    this.displayName,
    this.avatarName,
    this.stylePreference = 'abstract',
  })  : avatarType = UserAvatarProfile.avatarTypePrivateAbstract,
        agePresentation = 'not_applicable',
        skinTone = 'not_applicable',
        faceShape = 'not_applicable',
        hairType = 'not_applicable',
        hairStyle = 'not_applicable',
        hairColor = 'not_applicable',
        bodyShape = 'not_applicable',
        accessibilityItems = const <String>[],
        clothingItems = const <String>[],
        culturalItems = const <String>[];

  static const String avatarTypeLooksLikeMe = 'looks_like_me';
  static const String avatarTypeInspiredByMe = 'inspired_by_me';
  static const String avatarTypePrivateAbstract = 'private_abstract';
  static const String legacyAvatarTypeFantasyVersion = 'fantasy_version';

  static const Set<String> supportedAvatarTypes = <String>{
    avatarTypeLooksLikeMe,
    avatarTypeInspiredByMe,
    avatarTypePrivateAbstract,
  };

  static String normalizeAvatarType(String? value) {
    return switch (value) {
      avatarTypeLooksLikeMe => avatarTypeLooksLikeMe,
      avatarTypeInspiredByMe => avatarTypeInspiredByMe,
      avatarTypePrivateAbstract => avatarTypePrivateAbstract,
      legacyAvatarTypeFantasyVersion => avatarTypeInspiredByMe,
      _ => avatarTypeInspiredByMe,
    };
  }

  final String avatarType;
  final String agePresentation;
  final String skinTone;
  final String faceShape;
  final String hairType;
  final String hairStyle;
  final String hairColor;
  final String bodyShape;
  final List<String> accessibilityItems;
  final List<String> clothingItems;
  final List<String> culturalItems;
  final String moodStyle;
  final String backgroundColor;
  final String? pronouns;
  final String? displayName;
  final String? avatarName;
  final String stylePreference;

  String get normalizedAvatarType => normalizeAvatarType(avatarType);

  bool get isPrivacyFirst => normalizedAvatarType == avatarTypePrivateAbstract;

  bool get isPortrait => !isPrivacyFirst;

  bool get isHumanLike => isPortrait;

  UserAvatarProfile copyWith({
    String? avatarType,
    String? agePresentation,
    String? skinTone,
    String? faceShape,
    String? hairType,
    String? hairStyle,
    String? hairColor,
    String? bodyShape,
    List<String>? accessibilityItems,
    List<String>? clothingItems,
    List<String>? culturalItems,
    String? moodStyle,
    String? backgroundColor,
    String? pronouns,
    String? displayName,
    String? avatarName,
    String? stylePreference,
  }) {
    return UserAvatarProfile(
      avatarType: normalizeAvatarType(avatarType ?? this.avatarType),
      agePresentation: agePresentation ?? this.agePresentation,
      skinTone: skinTone ?? this.skinTone,
      faceShape: faceShape ?? this.faceShape,
      hairType: hairType ?? this.hairType,
      hairStyle: hairStyle ?? this.hairStyle,
      hairColor: hairColor ?? this.hairColor,
      bodyShape: bodyShape ?? this.bodyShape,
      accessibilityItems: accessibilityItems ?? this.accessibilityItems,
      clothingItems: clothingItems ?? this.clothingItems,
      culturalItems: culturalItems ?? this.culturalItems,
      moodStyle: moodStyle ?? this.moodStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      pronouns: pronouns ?? this.pronouns,
      displayName: displayName ?? this.displayName,
      avatarName: avatarName ?? this.avatarName,
      stylePreference: stylePreference ?? this.stylePreference,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'avatarType': normalizedAvatarType,
      'agePresentation': agePresentation,
      'skinTone': skinTone,
      'faceShape': faceShape,
      'hairType': hairType,
      'hairStyle': hairStyle,
      'hairColor': hairColor,
      'bodyShape': bodyShape,
      'accessibilityItems': accessibilityItems,
      'clothingItems': clothingItems,
      'culturalItems': culturalItems,
      'moodStyle': moodStyle,
      'backgroundColor': backgroundColor,
      if (pronouns != null) 'pronouns': pronouns,
      if (displayName != null) 'displayName': displayName,
      if (avatarName != null) 'avatarName': avatarName,
      'stylePreference': stylePreference,
    };
  }

  factory UserAvatarProfile.fromJson(Map<String, dynamic> json) {
    return UserAvatarProfile(
      avatarType: normalizeAvatarType(json['avatarType'] as String?),
      agePresentation: json['agePresentation'] as String? ?? 'adult',
      skinTone: json['skinTone'] as String? ?? 'medium',
      faceShape: json['faceShape'] as String? ?? 'soft_round',
      hairType: json['hairType'] as String? ?? 'wavy',
      hairStyle: json['hairStyle'] as String? ?? 'short',
      hairColor: json['hairColor'] as String? ?? 'brown',
      bodyShape: json['bodyShape'] as String? ?? 'average',
      accessibilityItems: _stringList(json['accessibilityItems']),
      clothingItems: _stringList(json['clothingItems'],
          fallback: const <String>['hoodie']),
      culturalItems: _stringList(json['culturalItems']),
      moodStyle: json['moodStyle'] as String? ?? 'calm',
      backgroundColor: json['backgroundColor'] as String? ?? 'soft_teal',
      pronouns: json['pronouns'] as String?,
      displayName: json['displayName'] as String?,
      avatarName: json['avatarName'] as String?,
      stylePreference: json['stylePreference'] as String? ?? 'soft_illustrated',
    );
  }

  static List<String> _stringList(
    Object? value, {
    List<String> fallback = const <String>[],
  }) {
    if (value is! List) return fallback;
    return value.whereType<String>().toList(growable: false);
  }
}

class UserAvatarLayer {
  const UserAvatarLayer({
    required this.assetPath,
    required this.semanticLabel,
    this.representsIdentity = true,
  });

  final String assetPath;
  final String semanticLabel;
  final bool representsIdentity;
}

class UserAvatarLayerResolver {
  const UserAvatarLayerResolver();

  static const String root = 'assets/user_avatar';

  List<UserAvatarLayer> layersFor(UserAvatarProfile profile) {
    if (profile.isPrivacyFirst) {
      return <UserAvatarLayer>[
        UserAvatarLayer(
          assetPath: '$root/backgrounds/${_slug(profile.backgroundColor)}.png',
          semanticLabel: 'soft portrait avatar background',
          representsIdentity: false,
        ),
        UserAvatarLayer(
          assetPath: '$root/abstract/orbs/${_slug(profile.moodStyle)}.png',
          semanticLabel: 'private abstract avatar mark',
          representsIdentity: false,
        ),
      ];
    }

    return <UserAvatarLayer>[
      UserAvatarLayer(
        assetPath: '$root/backgrounds/${_slug(profile.backgroundColor)}.png',
        semanticLabel: 'soft portrait avatar background',
        representsIdentity: false,
      ),
      UserAvatarLayer(
        assetPath: '$root/base/bodies/${_slug(profile.bodyShape)}.png',
        semanticLabel: 'head and shoulders body shape',
      ),
      UserAvatarLayer(
        assetPath: '$root/base/skin_tones/${_slug(profile.skinTone)}.png',
        semanticLabel: 'skin tone',
      ),
      UserAvatarLayer(
        assetPath: '$root/base/heads/${_slug(profile.faceShape)}.png',
        semanticLabel: 'natural portrait face shape',
      ),
      UserAvatarLayer(
        assetPath:
            '$root/hair/${_slug(profile.hairType)}/${_slug(profile.hairStyle)}_${_slug(profile.hairColor)}.png',
        semanticLabel: 'realistic hair texture',
      ),
      ...profile.clothingItems.map(
        (item) => UserAvatarLayer(
          assetPath:
              '$root/clothing/${_clothingCategory(item)}/${_slug(item)}.png',
          semanticLabel: 'clothing $item',
        ),
      ),
      ...profile.culturalItems.map(
        (item) => UserAvatarLayer(
          assetPath: '$root/cultural/${_slug(item)}/${_slug(item)}.png',
          semanticLabel: 'cultural item $item',
        ),
      ),
      ...profile.accessibilityItems.map(
        (item) => UserAvatarLayer(
          assetPath:
              '$root/accessibility/${_accessibilityCategory(item)}/${_slug(item)}.png',
          semanticLabel: 'accessibility item $item',
        ),
      ),
    ];
  }

  static String _slug(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  static String _clothingCategory(String item) {
    final slug = _slug(item);
    if (slug.contains('uniform')) return 'school';
    if (slug.contains('work')) return 'work';
    if (slug.contains('pyjama') || slug.contains('sleep')) return 'sleepwear';
    if (slug.contains('sport')) return 'sportswear';
    if (slug.contains('modest') || slug.contains('hijab')) return 'modest';
    return 'casual';
  }

  static String _accessibilityCategory(String item) {
    final slug = _slug(item);
    if (slug.contains('hearing') || slug.contains('cochlear')) {
      return 'hearing_aids';
    }
    if (slug.contains('wheelchair')) return 'wheelchairs';
    if (slug.contains('prosthetic') || slug.contains('limb')) {
      return 'prosthetics';
    }
    if (slug.contains('glucose') ||
        slug.contains('insulin') ||
        slug.contains('medical')) {
      return 'medical_devices';
    }
    if (slug.contains('sensory') || slug.contains('headphone')) {
      return 'sensory';
    }
    if (slug.contains('glasses')) return 'glasses';
    return 'sensory';
  }
}
