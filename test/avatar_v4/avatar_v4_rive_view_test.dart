import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dope_i_mine/avatar_engine_v4/avatar_engine_v4.dart';

void main() {
  testWidgets('AvatarRiveView shows diagnostic when base rig is missing',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AvatarRiveView(
            config: const AvatarV4Config(),
            size: 180,
            assetResolver: AvatarRiveAssetResolver(
              rootBundleOverride: _EmptyBundle(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('avatar-v4-missing-rig-diagnostic')),
      findsOneWidget,
    );
    expect(find.text('Avatar preview'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('avatar-v4-starter-visible-preview')),
      findsOneWidget,
    );
  });

  test('asset resolver reports missing rig without throwing', () async {
    final resolver = AvatarRiveAssetResolver(
      rootBundleOverride: _EmptyBundle(),
    );

    final result = await resolver.resolveAvailableRig(const AvatarV4Config());

    expect(result, isNull);
  });
}

class _EmptyBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) {
    throw FlutterError('Missing asset: $key');
  }
}
