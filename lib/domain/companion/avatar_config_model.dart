import 'package:flutter/material.dart';

import '../avatar/avatar_enums.dart';
import '../avatar/user_avatar_profile.dart' as avatar;

class AvatarConfigModel {
  const AvatarConfigModel({
    required this.avatarStyle,
    required this.avatarPalette,
    required this.accessoryConfig,
  });

  static const String modeLooksLikeMe = 'looks_like_me';
  static const String modeInspiredByMe = 'inspired_by_me';
  static const String modePrivateAbstract = 'private_abstract';

  static const String paletteSoftIllustrated = 'soft_illustrated';
  static const String paletteNatural = 'natural';
  static const String paletteExpressiveNeon = 'expressive_neon';

  static const String defaultAvatarMode = modeInspiredByMe;
  static const String defaultAvatarPalette = paletteSoftIllustrated;

  static const AvatarConfigModel defaults = AvatarConfigModel(
    avatarStyle: defaultAvatarMode,
    avatarPalette: defaultAvatarPalette,
    accessoryConfig: <String, dynamic>{},
  );

  static String normalizeAvatarMode(String? value) {
    return switch (value) {
      modeLooksLikeMe => modeLooksLikeMe,
      modeInspiredByMe => modeInspiredByMe,
      modePrivateAbstract => modePrivateAbstract,
      'private' => modePrivateAbstract,
      'private_abstract_avatar' => modePrivateAbstract,
      'calm_orb' => modePrivateAbstract,
      'abstract' => modePrivateAbstract,
      'fox' || 'owl' || 'robot' || 'fantasy_version' => modeInspiredByMe,
      _ => defaultAvatarMode,
    };
  }

  static String normalizeAvatarPalette(String? value) {
    return switch (value) {
      paletteSoftIllustrated => paletteSoftIllustrated,
      paletteNatural => paletteNatural,
      paletteExpressiveNeon => paletteExpressiveNeon,
      'soft' => paletteSoftIllustrated,
      'neutral' => paletteNatural,
      'bright' => paletteExpressiveNeon,
      _ => defaultAvatarPalette,
    };
  }

  factory AvatarConfigModel.fromUserAvatarProfile(
    avatar.UserAvatarProfile profile,
  ) {
    return AvatarConfigModel(
      avatarStyle: _avatarStyleForProfile(profile),
      avatarPalette: _avatarPaletteForProfile(profile),
      accessoryConfig: <String, dynamic>{
        'profile': profile.toJson(),
      },
    );
  }

  String get normalizedAvatarStyle => normalizeAvatarMode(avatarStyle);

  String get normalizedAvatarPalette => normalizeAvatarPalette(avatarPalette);

  String get displayLabel {
    return '${avatarModeLabel(normalizedAvatarStyle)}, '
        '${avatarPaletteLabel(normalizedAvatarPalette)}';
  }

  avatar.UserAvatarProfile toUserAvatarProfile() {
    final storedProfile =
        _storedProfile() ?? avatar.UserAvatarProfile.defaultAdult;
    final mode = _modeForAvatarStyle(normalizedAvatarStyle);

    var profile = storedProfile.copyWith(mode: mode);
    if (mode == AvatarMode.privateAbstract) {
      profile = profile.copyWith(
        renderMode: AvatarRenderMode.abstract,
        realismLevel: AvatarRealismLevel.soft,
      );
    } else if (profile.renderMode == AvatarRenderMode.abstract) {
      profile = profile.copyWith(renderMode: AvatarRenderMode.premiumPortrait);
    }

    return _applyPalette(profile, normalizedAvatarPalette);
  }

  static String avatarModeLabel(String value) {
    return switch (normalizeAvatarMode(value)) {
      modeLooksLikeMe => 'Looks like me',
      modePrivateAbstract => 'Private / abstract',
      _ => 'Inspired by me',
    };
  }

  static String avatarPaletteLabel(String value) {
    return switch (normalizeAvatarPalette(value)) {
      paletteNatural => 'natural portrait',
      paletteExpressiveNeon => 'expressive neon portrait',
      _ => 'soft illustrated portrait',
    };
  }

  final String avatarStyle;
  final String avatarPalette;
  final Map<String, dynamic> accessoryConfig;

  avatar.UserAvatarProfile? _storedProfile() {
    final rawProfile = accessoryConfig['profile'];
    if (rawProfile is Map) {
      try {
        return avatar.UserAvatarProfile.fromJson(
          Map<String, dynamic>.from(rawProfile),
        );
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static String _avatarStyleForProfile(avatar.UserAvatarProfile profile) {
    return switch (profile.mode) {
      AvatarMode.looksLikeMe => modeLooksLikeMe,
      AvatarMode.privateAbstract => modePrivateAbstract,
      AvatarMode.inspiredByMe => modeInspiredByMe,
    };
  }

  static String _avatarPaletteForProfile(avatar.UserAvatarProfile profile) {
    if (profile.lightingStyle == AvatarLightingStyle.neon) {
      return paletteExpressiveNeon;
    }
    if (profile.realismLevel == AvatarRealismLevel.semiRealistic ||
        profile.realismLevel == AvatarRealismLevel.ultraRealistic ||
        profile.renderMode == AvatarRenderMode.ultraRealistic) {
      return paletteNatural;
    }
    return paletteSoftIllustrated;
  }

  static AvatarMode _modeForAvatarStyle(String avatarStyle) {
    return switch (normalizeAvatarMode(avatarStyle)) {
      modeLooksLikeMe => AvatarMode.looksLikeMe,
      modePrivateAbstract => AvatarMode.privateAbstract,
      _ => AvatarMode.inspiredByMe,
    };
  }

  static avatar.UserAvatarProfile _applyPalette(
    avatar.UserAvatarProfile profile,
    String palette,
  ) {
    return switch (normalizeAvatarPalette(palette)) {
      paletteNatural => profile.copyWith(
          realismLevel: profile.renderMode == AvatarRenderMode.ultraRealistic
              ? AvatarRealismLevel.ultraRealistic
              : AvatarRealismLevel.semiRealistic,
          lightingStyle: AvatarLightingStyle.studio,
          backgroundColor: const Color(0xFF111827),
          accentColor: const Color(0xFF34D399),
        ),
      paletteExpressiveNeon => profile.copyWith(
          lightingStyle: AvatarLightingStyle.neon,
          backgroundColor: const Color(0xFF0F1025),
          accentColor: const Color(0xFFEC4899),
        ),
      _ => profile.copyWith(
          realismLevel: profile.renderMode == AvatarRenderMode.ultraRealistic
              ? profile.realismLevel
              : AvatarRealismLevel.soft,
          lightingStyle: AvatarLightingStyle.softNatural,
          backgroundColor: const Color(0xFF101827),
          accentColor: const Color(0xFF22D3EE),
        ),
    };
  }
}
