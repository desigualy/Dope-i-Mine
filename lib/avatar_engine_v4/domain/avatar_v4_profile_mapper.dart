import 'package:flutter/material.dart';

import '../../domain/avatar/user_avatar_profile.dart' as typed_profile;
import '../../domain/user_avatar/user_avatar_profile.dart' as string_profile;
import 'avatar_v4_config.dart';

class AvatarV4ProfileMapper {
  const AvatarV4ProfileMapper._();

  static AvatarV4Config fromAny(Object? value) {
    if (value is AvatarV4Config) return value;
    if (value is typed_profile.UserAvatarProfile) return fromTypedProfile(value);
    if (value is string_profile.UserAvatarProfile) return fromStringProfile(value);
    if (value is Map<String, dynamic>) return fromJsonLike(value);
    if (value is Map) return fromJsonLike(Map<String, dynamic>.from(value));
    return AvatarV4Config.starter();
  }

  static AvatarV4Config fromTypedProfile(typed_profile.UserAvatarProfile value) {
    final accessoryIds = <String>{
      ...value.accessibilityItems.map((item) => _token(item.name)),
      if (value.culturalItem.name != 'none') _token(value.culturalItem.name),
    }.where((item) => item.isNotEmpty).toList(growable: false);

    return AvatarV4Config.starter().copyWith(
      skinTone: _skinToneFromColor(value.skinTone),
      faceShape: _faceShape(value.faceShape.name),
      hairPackId: _hairPackId(value.hairType.name, value.hairStyle.name),
      hairStyleId: _hairStyleId(value.hairType.name, value.hairStyle.name),
      hairColor: _hairColorFromColor(value.hairColor),
      freckles: value.skinDetail.name == 'freckles',
      vitiligo: value.skinDetail.name == 'vitiligo',
      birthmarkIds: value.skinDetail.name == 'birthmark'
          ? const <String>['birthmark_default']
          : const <String>[],
      scarIds: value.skinDetail.name == 'scar'
          ? const <String>['scar_default']
          : const <String>[],
      matureLineIds: value.skinDetail.name == 'matureLines'
          ? const <String>['soft_mature_lines']
          : const <String>[],
      facialHairStyleId: _facialHair(value.facialHair.name),
      bodyPresetId: _body(value.bodyPresentation.name),
      accessoryIds: accessoryIds,
    );
  }

  static AvatarV4Config fromStringProfile(string_profile.UserAvatarProfile value) {
    final accessoryIds = <String>{
      ...value.accessibilityItems.map(_token),
      ...value.culturalItems.map(_token),
    }.where((item) => item.isNotEmpty).toList(growable: false);

    return AvatarV4Config.starter().copyWith(
      skinTone: _skinToneFromString(value.skinTone),
      faceShape: _faceShape(value.faceShape),
      hairPackId: _hairPackId(value.hairType, value.hairStyle),
      hairStyleId: _hairStyleId(value.hairType, value.hairStyle),
      hairColor: _hairColorFromString(value.hairColor),
      facialHairStyleId: _facialHair(value.facialHair),
      bodyPresetId: _body(value.bodyShape),
      accessoryIds: accessoryIds,
    );
  }

  static AvatarV4Config fromJsonLike(Map<String, dynamic> json) {
    if (json.containsKey('rigAssetPath') || json.containsKey('hairPackId')) {
      return AvatarV4Config.fromJson(json);
    }

    final stringValue = string_profile.UserAvatarProfile.fromJson(json);
    return fromStringProfile(stringValue);
  }

  static String _skinToneFromColor(Color color) {
    final red = color.red;
    final green = color.green;
    final blue = color.blue;
    final brightness = (red + green + blue) / 3;

    if (brightness >= 205) return 'fair_warm';
    if (brightness >= 160) return 'light_warm';
    if (brightness >= 110) return 'tan_warm';
    if (brightness >= 75) return 'medium_brown';
    return 'deep_brown';
  }

  static String _skinToneFromString(String value) {
    return switch (_token(value)) {
      'fair' || 'light' || 'pale' => 'fair_warm',
      'medium' || 'tan' || 'olive' => 'tan_warm',
      'brown' || 'medium_brown' => 'medium_brown',
      'dark' || 'deep' || 'deep_brown' => 'deep_brown',
      _ => 'tan_warm',
    };
  }

  static String _faceShape(String value) {
    return switch (_token(value)) {
      'round' || 'soft_round' => 'round',
      'square' => 'square',
      'heart' => 'heart',
      'long' => 'long',
      'oval' || 'soft_oval' => 'soft_oval',
      _ => 'soft_oval',
    };
  }

  static String _hairPackId(String hairType, String hairStyle) {
    final type = _token(hairType);
    final style = _token(hairStyle);

    if (type == 'none' || type == 'bald' || style == 'none') {
      return 'hair_none_v1';
    }
    if (type == 'covered' || style.contains('headwrap')) {
      return 'hair_covered_v1';
    }
    if (type == 'braids' || style.contains('braid')) return 'hair_braids_v1';
    if (type == 'locs' || style.contains('loc')) return 'hair_locs_v1';
    if (type == 'twists' || style.contains('twist')) return 'hair_twists_v1';
    if (type == 'afro' || style.contains('afro') || style.contains('ringlet')) {
      return 'hair_ringlet_afro_v1';
    }
    if (type == 'curly' || style.contains('curl')) return 'hair_curly_v1';
    if (type == 'wavy' || style.contains('wavy')) return 'hair_wavy_v1';
    if (type == 'straight') return 'hair_straight_v1';
    if (type == 'shaved') return 'hair_shaved_v1';
    return 'hair_ringlet_afro_v1';
  }

  static String _hairStyleId(String hairType, String hairStyle) {
    final type = _token(hairType);
    final style = _token(hairStyle);

    if (type == 'none' || type == 'bald' || style == 'none') return 'none';
    if (style.contains('ringlet') || style.contains('afro')) {
      return 'long_copper_ringlet_afro';
    }
    if (style.contains('braid')) return 'starter_braids';
    if (style.contains('loc')) return 'starter_locs';
    if (style.contains('twist')) return 'starter_twists';
    if (style.contains('curl')) return 'starter_curls';
    if (style.contains('wavy')) return 'starter_waves';
    if (type == 'covered') return 'starter_head_covering';
    if (type == 'shaved') return 'starter_shaved';
    return 'starter_natural';
  }

  static String _hairColorFromColor(Color color) {
    final red = color.red;
    final green = color.green;
    final blue = color.blue;

    if (red > 150 && green > 125 && blue > 85) return 'blonde';
    if (red > 120 && green < 95 && blue < 70) return 'copper_brown';
    if (red > 95 && green > 95 && blue > 95) return 'grey';
    if (red < 55 && green < 55 && blue < 55) return 'black';
    return 'brown';
  }

  static String _hairColorFromString(String value) {
    return switch (_token(value)) {
      'black' => 'black',
      'dark_brown' => 'dark_brown',
      'light_brown' => 'light_brown',
      'blonde' => 'blonde',
      'ginger' || 'auburn' || 'copper' || 'copper_brown' => 'copper_brown',
      'grey' || 'gray' => 'grey',
      'white' => 'white',
      'dyed' => 'dyed',
      _ => 'brown',
    };
  }

  static String _facialHair(String value) {
    return switch (_token(value)) {
      'light_stubble' => 'light_stubble',
      'moustache' || 'mustache' => 'moustache',
      'goatee' => 'goatee',
      'short_beard' => 'short_beard',
      'full_beard' => 'full_beard',
      _ => 'none',
    };
  }

  static String _body(String value) {
    return switch (_token(value)) {
      'petite' => 'petite_soft',
      'slim' => 'slim_soft',
      'broad' => 'broad_soft',
      'larger' || 'larger_body' => 'larger_soft',
      'muscular' => 'muscular_soft',
      'seated' => 'seated_soft',
      _ => 'average_soft',
    };
  }

  static String _token(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'(?<=[a-z0-9])(?=[A-Z])'), '_')
        .replaceAll('-', '_')
        .replaceAll(' ', '_')
        .toLowerCase();
  }
}
