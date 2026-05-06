import 'package:flutter/services.dart' as services;

import '../domain/avatar_v4_config.dart';

class AvatarRiveAssetResolver {
  AvatarRiveAssetResolver({
    services.AssetBundle? rootBundleOverride,
  }) : bundle = rootBundleOverride ?? services.rootBundle;

  final services.AssetBundle bundle;

  Future<bool> exists(String assetPath) async {
    try {
      final data = await bundle.load(assetPath);
      return data.lengthInBytes > 0;
    } catch (_) {
      return false;
    }
  }

  Future<String?> resolveAvailableRig(AvatarV4Config config) async {
    if (await exists(config.rigAssetPath)) {
      return config.rigAssetPath;
    }

    if (config.rigAssetPath != AvatarV4Config.defaultBaseRigAssetPath &&
        await exists(AvatarV4Config.defaultBaseRigAssetPath)) {
      return AvatarV4Config.defaultBaseRigAssetPath;
    }

    return null;
  }
}
