import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dope_i_mine/avatar_engine_v4/avatar_engine_v4.dart';

void main() {
  tearDown(AvatarRiveRuntimeInitializer.resetForTesting);

  test('validator reports missing asset when bundle cannot load rig', () async {
    final validator = AvatarRiveContractValidator(
      bundle: _MissingAssetBundle(),
      initializeNativeRuntime: false,
      parseRiveFile: false,
    );

    final result = await validator.validate();

    expect(result.isValid, isFalse);
    expect(result.canAttemptRender, isFalse);
    expect(result.issues.single.code, AvatarV4RiveContractIssueCode.missingAsset);
  });

  test('validator reports unreadable asset without native Rive import in pure Dart tests',
      () async {
    AvatarRiveRuntimeInitializer.setNativeInitializationEnabledForTesting(false);

    final validator = AvatarRiveContractValidator(
      bundle: _InvalidRiveBundle(),
      initializeNativeRuntime: false,
      parseRiveFile: false,
    );

    final result = await validator.validate();

    expect(result.isValid, isFalse);
    expect(result.canAttemptRender, isFalse);
    expect(
      result.issues.single.code,
      AvatarV4RiveContractIssueCode.unreadableAsset,
    );
    expect(result.summary, contains('Rive parsing is disabled'));
  });
}

class _MissingAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) {
    throw FlutterError('missing asset: $key');
  }
}

class _InvalidRiveBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    return ByteData(8);
  }
}
