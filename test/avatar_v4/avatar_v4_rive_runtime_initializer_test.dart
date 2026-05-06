import 'package:flutter_test/flutter_test.dart';

import 'package:dope_i_mine/avatar_engine_v4/avatar_engine_v4.dart';

void main() {
  tearDown(AvatarRiveRuntimeInitializer.resetForTesting);

  test('Rive runtime initializer can be disabled for pure Dart tests', () async {
    AvatarRiveRuntimeInitializer.setNativeInitializationEnabledForTesting(false);

    final first = await AvatarRiveRuntimeInitializer.ensureInitialized();
    final second = await AvatarRiveRuntimeInitializer.ensureInitialized();

    expect(first, isNull);
    expect(second, isNull);
  });
}
