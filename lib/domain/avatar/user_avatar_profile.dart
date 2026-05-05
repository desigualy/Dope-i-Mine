import 'package:flutter/material.dart';

import 'avatar_enums.dart';

@immutable
class UserAvatarProfile {
  const UserAvatarProfile({
    required this.mode,
    required this.renderMode,
    required this.realismLevel,
    required this.lightingStyle,
    required this.cameraStyle,
    required this.agePresentation,
    required this.bodyPresentation,
    required this.skinTone,
    required this.skinDetail,
    required this.hairType,
    required this.hairLength,
    required this.hairStyle,
    required this.hairColor,
    this.facialHair = AvatarFacialHair.none,
    required this.faceShape,
    required this.expression,
    this.accessibilityItems = const <AvatarAccessibilityItem>[],
    this.culturalItem = AvatarCulturalItem.none,
    this.backgroundColor = const Color(0xFF101827),
    this.accentColor = const Color(0xFF22D3EE),
    this.generatedImageUrl,
    this.localImagePath,
  });

  final AvatarMode mode;
  final AvatarRenderMode renderMode;
  final AvatarRealismLevel realismLevel;
  final AvatarLightingStyle lightingStyle;
  final AvatarCameraStyle cameraStyle;
  final AvatarAgePresentation agePresentation;
  final AvatarBodyPresentation bodyPresentation;
  final Color skinTone;
  final AvatarSkinDetail skinDetail;
  final AvatarHairType hairType;
  final AvatarHairLength hairLength;
  final AvatarHairStyle hairStyle;
  final Color hairColor;
  final AvatarFacialHair facialHair;
  final AvatarFaceShape faceShape;
  final AvatarExpression expression;
  final List<AvatarAccessibilityItem> accessibilityItems;
  final AvatarCulturalItem culturalItem;
  final Color backgroundColor;
  final Color accentColor;
  final String? generatedImageUrl;
  final String? localImagePath;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'mode': mode.name,
      'renderMode': renderMode.name,
      'realismLevel': realismLevel.name,
      'lightingStyle': lightingStyle.name,
      'cameraStyle': cameraStyle.name,
      'agePresentation': agePresentation.name,
      'bodyPresentation': bodyPresentation.name,
      'skinTone': skinTone.value,
      'skinDetail': skinDetail.name,
      'hairType': hairType.name,
      'hairLength': hairLength.name,
      'hairStyle': hairStyle.name,
      'hairColor': hairColor.value,
      'facialHair': facialHair.name,
      'faceShape': faceShape.name,
      'expression': expression.name,
      'accessibilityItems':
          accessibilityItems.map((item) => item.name).toList(),
      'culturalItem': culturalItem.name,
      'backgroundColor': backgroundColor.value,
      'accentColor': accentColor.value,
      if (generatedImageUrl?.isNotEmpty == true)
        'generatedImageUrl': generatedImageUrl,
      if (localImagePath?.isNotEmpty == true) 'localImagePath': localImagePath,
    };
  }

  factory UserAvatarProfile.fromJson(Map<String, dynamic> json) {
    return UserAvatarProfile(
      mode: _enumByName(
        json['mode'],
        AvatarMode.values,
        defaultAdult.mode,
        aliases: const <String, AvatarMode>{
          'looks_like_me': AvatarMode.looksLikeMe,
          'inspired_by_me': AvatarMode.inspiredByMe,
          'private_abstract': AvatarMode.privateAbstract,
        },
      ),
      renderMode: _enumByName(
        json['renderMode'],
        AvatarRenderMode.values,
        defaultAdult.renderMode,
        aliases: const <String, AvatarRenderMode>{
          'premium_portrait': AvatarRenderMode.premiumPortrait,
          'ultra_realistic': AvatarRenderMode.ultraRealistic,
          'private_abstract': AvatarRenderMode.abstract,
        },
      ),
      realismLevel: _enumByName(
        json['realismLevel'],
        AvatarRealismLevel.values,
        defaultAdult.realismLevel,
        aliases: const <String, AvatarRealismLevel>{
          'semi_realistic': AvatarRealismLevel.semiRealistic,
          'ultra_realistic': AvatarRealismLevel.ultraRealistic,
        },
      ),
      lightingStyle: _enumByName(
        json['lightingStyle'],
        AvatarLightingStyle.values,
        defaultAdult.lightingStyle,
        aliases: const <String, AvatarLightingStyle>{
          'soft_natural': AvatarLightingStyle.softNatural,
        },
      ),
      cameraStyle: _enumByName(
        json['cameraStyle'],
        AvatarCameraStyle.values,
        defaultAdult.cameraStyle,
      ),
      agePresentation: _enumByName(
        json['agePresentation'],
        AvatarAgePresentation.values,
        defaultAdult.agePresentation,
        aliases: const <String, AvatarAgePresentation>{
          'pre_teen': AvatarAgePresentation.preTeen,
          'young_adult': AvatarAgePresentation.youngAdult,
          'older_adult': AvatarAgePresentation.olderAdult,
        },
      ),
      bodyPresentation: _enumByName(
        json['bodyPresentation'],
        AvatarBodyPresentation.values,
        defaultAdult.bodyPresentation,
      ),
      skinTone: _colorFromJson(json['skinTone'], defaultAdult.skinTone),
      skinDetail: _enumByName(
        json['skinDetail'],
        AvatarSkinDetail.values,
        defaultAdult.skinDetail,
        aliases: const <String, AvatarSkinDetail>{
          'mature_lines': AvatarSkinDetail.matureLines,
        },
      ),
      hairType: _enumByName(
        json['hairType'],
        AvatarHairType.values,
        defaultAdult.hairType,
      ),
      hairLength: _enumByName(
        json['hairLength'],
        AvatarHairLength.values,
        defaultAdult.hairLength,
      ),
      hairStyle: _enumByName(
        json['hairStyle'],
        AvatarHairStyle.values,
        defaultAdult.hairStyle,
        aliases: const <String, AvatarHairStyle>{
          'short_curls': AvatarHairStyle.shortCurls,
          'shoulder_length_curls': AvatarHairStyle.shoulderLengthCurls,
          'full_curly_afro': AvatarHairStyle.fullCurlyAfro,
          'curly_afro_with_side_part': AvatarHairStyle.curlyAfroWithSidePart,
          'long_ringlets': AvatarHairStyle.longRinglets,
          'protective_style': AvatarHairStyle.protectiveStyle,
          'afro': AvatarHairStyle.fullCurlyAfro,
          'side_part_afro': AvatarHairStyle.curlyAfroWithSidePart,
        },
      ),
      hairColor: _colorFromJson(json['hairColor'], defaultAdult.hairColor),
      facialHair: _facialHairForAge(
        _enumByName(
          json['facialHair'],
          AvatarFacialHair.values,
          defaultAdult.facialHair,
          aliases: const <String, AvatarFacialHair>{
            'light_stubble': AvatarFacialHair.lightStubble,
            'short_beard': AvatarFacialHair.shortBeard,
            'full_beard': AvatarFacialHair.fullBeard,
          },
        ),
        _enumByName(
          json['agePresentation'],
          AvatarAgePresentation.values,
          defaultAdult.agePresentation,
          aliases: const <String, AvatarAgePresentation>{
            'pre_teen': AvatarAgePresentation.preTeen,
            'young_adult': AvatarAgePresentation.youngAdult,
            'older_adult': AvatarAgePresentation.olderAdult,
          },
        ),
      ),
      faceShape: _enumByName(
        json['faceShape'],
        AvatarFaceShape.values,
        defaultAdult.faceShape,
      ),
      expression: _enumByName(
        json['expression'],
        AvatarExpression.values,
        defaultAdult.expression,
      ),
      accessibilityItems: _enumListByName(
        json['accessibilityItems'],
        AvatarAccessibilityItem.values,
      ),
      culturalItem: _enumByName(
        json['culturalItem'],
        AvatarCulturalItem.values,
        defaultAdult.culturalItem,
      ),
      backgroundColor:
          _colorFromJson(json['backgroundColor'], defaultAdult.backgroundColor),
      accentColor:
          _colorFromJson(json['accentColor'], defaultAdult.accentColor),
      generatedImageUrl: json['generatedImageUrl'] as String?,
      localImagePath: json['localImagePath'] as String?,
    );
  }

  UserAvatarProfile copyWith({
    AvatarMode? mode,
    AvatarRenderMode? renderMode,
    AvatarRealismLevel? realismLevel,
    AvatarLightingStyle? lightingStyle,
    AvatarCameraStyle? cameraStyle,
    AvatarAgePresentation? agePresentation,
    AvatarBodyPresentation? bodyPresentation,
    Color? skinTone,
    AvatarSkinDetail? skinDetail,
    AvatarHairType? hairType,
    AvatarHairLength? hairLength,
    AvatarHairStyle? hairStyle,
    Color? hairColor,
    AvatarFacialHair? facialHair,
    AvatarFaceShape? faceShape,
    AvatarExpression? expression,
    List<AvatarAccessibilityItem>? accessibilityItems,
    AvatarCulturalItem? culturalItem,
    Color? backgroundColor,
    Color? accentColor,
    String? generatedImageUrl,
    String? localImagePath,
    bool clearGeneratedImageUrl = false,
    bool clearLocalImagePath = false,
  }) {
    return UserAvatarProfile(
      mode: mode ?? this.mode,
      renderMode: renderMode ?? this.renderMode,
      realismLevel: realismLevel ?? this.realismLevel,
      lightingStyle: lightingStyle ?? this.lightingStyle,
      cameraStyle: cameraStyle ?? this.cameraStyle,
      agePresentation: agePresentation ?? this.agePresentation,
      bodyPresentation: bodyPresentation ?? this.bodyPresentation,
      skinTone: skinTone ?? this.skinTone,
      skinDetail: skinDetail ?? this.skinDetail,
      hairType: hairType ?? this.hairType,
      hairLength: hairLength ?? this.hairLength,
      hairStyle: hairStyle ?? this.hairStyle,
      hairColor: hairColor ?? this.hairColor,
      facialHair: _facialHairForAge(
        facialHair ?? this.facialHair,
        agePresentation ?? this.agePresentation,
      ),
      faceShape: faceShape ?? this.faceShape,
      expression: expression ?? this.expression,
      accessibilityItems: accessibilityItems ?? this.accessibilityItems,
      culturalItem: culturalItem ?? this.culturalItem,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      accentColor: accentColor ?? this.accentColor,
      generatedImageUrl: clearGeneratedImageUrl
          ? null
          : generatedImageUrl ?? this.generatedImageUrl,
      localImagePath:
          clearLocalImagePath ? null : localImagePath ?? this.localImagePath,
    );
  }

  static const UserAvatarProfile defaultAdult = UserAvatarProfile(
    mode: AvatarMode.inspiredByMe,
    renderMode: AvatarRenderMode.premiumPortrait,
    realismLevel: AvatarRealismLevel.soft,
    lightingStyle: AvatarLightingStyle.softNatural,
    cameraStyle: AvatarCameraStyle.shoulders,
    agePresentation: AvatarAgePresentation.adult,
    bodyPresentation: AvatarBodyPresentation.average,
    skinTone: Color(0xFFB87952),
    skinDetail: AvatarSkinDetail.none,
    hairType: AvatarHairType.curly,
    hairLength: AvatarHairLength.medium,
    hairStyle: AvatarHairStyle.curlyAfroWithSidePart,
    hairColor: Color(0xFFA04000),
    facialHair: AvatarFacialHair.none,
    faceShape: AvatarFaceShape.oval,
    expression: AvatarExpression.calm,
  );

  static AvatarFacialHair _facialHairForAge(
    AvatarFacialHair facialHair,
    AvatarAgePresentation agePresentation,
  ) {
    if (agePresentation == AvatarAgePresentation.child ||
        agePresentation == AvatarAgePresentation.preTeen) {
      return AvatarFacialHair.none;
    }
    return facialHair;
  }

  static T _enumByName<T extends Enum>(
    Object? value,
    List<T> values,
    T fallback, {
    Map<String, T>? aliases,
  }) {
    if (value is! String || value.isEmpty) return fallback;
    final normalized = _normalizeToken(value);
    return aliases?[normalized] ??
        values.firstWhere(
          (item) => _normalizeToken(item.name) == normalized,
          orElse: () => fallback,
        );
  }

  static List<T> _enumListByName<T extends Enum>(
    Object? value,
    List<T> values,
  ) {
    if (value is! List) return <T>[];
    return value
        .whereType<String>()
        .map((item) => _enumByName<T>(item, values, values.first))
        .toList(growable: false);
  }

  static Color _colorFromJson(Object? value, Color fallback) {
    if (value is int) return Color(value);
    if (value is String && value.isNotEmpty) {
      final cleaned = value.replaceFirst('#', '').replaceFirst('0x', '');
      final parsed = int.tryParse(cleaned, radix: 16);
      if (parsed != null) {
        if (cleaned.length <= 6) return Color(0xFF000000 | parsed);
        return Color(parsed);
      }
    }
    return fallback;
  }

  static String _normalizeToken(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'(?<=[a-z0-9])(?=[A-Z])'), '_')
        .replaceAll('-', '_')
        .toLowerCase();
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is UserAvatarProfile &&
            other.mode == mode &&
            other.renderMode == renderMode &&
            other.realismLevel == realismLevel &&
            other.lightingStyle == lightingStyle &&
            other.cameraStyle == cameraStyle &&
            other.agePresentation == agePresentation &&
            other.bodyPresentation == bodyPresentation &&
            other.skinTone == skinTone &&
            other.skinDetail == skinDetail &&
            other.hairType == hairType &&
            other.hairLength == hairLength &&
            other.hairStyle == hairStyle &&
            other.hairColor == hairColor &&
            other.facialHair == facialHair &&
            other.faceShape == faceShape &&
            other.expression == expression &&
            _listEquals(other.accessibilityItems, accessibilityItems) &&
            other.culturalItem == culturalItem &&
            other.backgroundColor == backgroundColor &&
            other.accentColor == accentColor &&
            other.generatedImageUrl == generatedImageUrl &&
            other.localImagePath == localImagePath;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
        mode,
        renderMode,
        realismLevel,
        lightingStyle,
        cameraStyle,
        agePresentation,
        bodyPresentation,
        skinTone,
        skinDetail,
        hairType,
        hairLength,
        hairStyle,
        hairColor,
        facialHair,
        faceShape,
        expression,
        Object.hashAll(accessibilityItems),
        culturalItem,
        backgroundColor,
        accentColor,
        generatedImageUrl,
        localImagePath,
      ]);

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i += 1) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
