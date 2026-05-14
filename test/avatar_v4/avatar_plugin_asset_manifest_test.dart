import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dope_i_mine/avatar_engine_v4/avatar_engine_v4.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('plugin asset manifest loads and resolves starter trait bindings',
      () async {
    final raw = await rootBundle.loadString(avatarPluginAssetManifestPath);
    final manifest = AvatarPluginAssetManifest.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );

    expect(manifest.rive.assetPath, 'assets/avatar_rive/base_avatar.riv');
    expect(manifest.rive.artboard, 'Avatar');
    expect(manifest.rive.stateMachine, 'AvatarState');
    expect(manifest.checklist, isNotEmpty);

    final resolved = AvatarPluginAssetResolver(manifest).resolveTraitIds(
      const <String>['tan_warm', 'long_wavy', 'wheelchair', 'missing_trait'],
    );

    expect(resolved.riveInputs['skinTone'], 0.58);
    expect(resolved.riveInputs['hairStyle'], 0.62);
    expect(resolved.glbAssetPaths,
        contains('assets/avatar_glb/accessibility/wheelchair.glb'));
    expect(resolved.missingTraitIds, contains('missing_trait'));
  });
}
