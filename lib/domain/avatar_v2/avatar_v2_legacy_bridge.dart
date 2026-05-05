import '../companion/avatar_config_model.dart';
import 'avatar_v2_profile.dart';
import 'avatar_v2_validation.dart';

class AvatarV2LegacyBridge {
  const AvatarV2LegacyBridge._();

  static AvatarV2Profile fromAvatarConfig(AvatarConfigModel config) {
    final mode = switch (config.normalizedAvatarStyle) {
      AvatarConfigModel.modeLooksLikeMe => AvatarV2Mode.looksLikeMe,
      AvatarConfigModel.modePrivateAbstract => AvatarV2Mode.privateAbstract,
      _ => AvatarV2Mode.inspiredByMe,
    };

    final realism = switch (config.normalizedAvatarPalette) {
      AvatarConfigModel.paletteAppleMetaRealistic =>
        AvatarV2RealismLevel.realistic,
      AvatarConfigModel.paletteNatural => AvatarV2RealismLevel.semiRealistic,
      _ => AvatarV2RealismLevel.semiRealistic,
    };

    final lighting = switch (config.normalizedAvatarPalette) {
      AvatarConfigModel.paletteExpressiveNeon => AvatarV2LightingStyle.dramatic,
      AvatarConfigModel.paletteNatural => AvatarV2LightingStyle.naturalDaylight,
      _ => AvatarV2LightingStyle.softStudio,
    };

    final renderMode = mode == AvatarV2Mode.privateAbstract
        ? AvatarV2RenderMode.realtimeVector
        : AvatarV2RenderMode.hybrid;

    final profile = AvatarV2Profile(
      mode: mode,
      renderMode: renderMode,
      realismLevel: realism,
      lightingStyle: lighting,
      cameraStyle: AvatarV2CameraStyle.headAndShoulders,
      updatedAt: DateTime.now().toUtc(),
    );

    return AvatarV2Validation.validate(profile).normalized ?? profile;
  }

  static AvatarConfigModel toLegacyAvatarConfig(AvatarV2Profile profile) {
    final style = switch (profile.mode) {
      AvatarV2Mode.looksLikeMe => AvatarConfigModel.modeLooksLikeMe,
      AvatarV2Mode.privateAbstract => AvatarConfigModel.modePrivateAbstract,
      AvatarV2Mode.inspiredByMe => AvatarConfigModel.modeInspiredByMe,
    };

    final palette = switch (profile.realismLevel) {
      AvatarV2RealismLevel.realistic =>
        AvatarConfigModel.paletteAppleMetaRealistic,
      AvatarV2RealismLevel.semiRealistic => AvatarConfigModel.paletteNatural,
      AvatarV2RealismLevel.soft => AvatarConfigModel.paletteSoftIllustrated,
    };

    return AvatarConfigModel(
      avatarStyle: style,
      avatarPalette: profile.lightingStyle == AvatarV2LightingStyle.dramatic
          ? AvatarConfigModel.paletteExpressiveNeon
          : palette,
      accessoryConfig: <String, dynamic>{
        'avatarV2Profile': profile.toJson(),
        'avatarEngine': 'avatar_v2',
      },
    );
  }
}
