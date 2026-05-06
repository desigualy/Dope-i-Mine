import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dope_i_mine/presentation/avatar/avatar_engine_bridge.dart';
import 'package:dope_i_mine/presentation/avatar_v3/avatar_v3_renderer.dart';

void main() {
  testWidgets('Avatar V3 renderer is never blank with default profile',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AvatarV3Renderer(size: 180),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('avatar-v3-renderer')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('avatar-v3-layer-stack')),
      findsOneWidget,
    );

    final size = tester.getSize(
      find.byKey(const ValueKey<String>('avatar-v3-renderer')),
    );
    expect(size.width, greaterThan(0));
    expect(size.height, greaterThan(0));
  });

  testWidgets('Avatar engine bridge supplies visible V3 default on null profile',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AvatarEngineBridge(profile: null, size: 180),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('avatar-v3-renderer')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('avatar-v3-layer-stack')),
      findsOneWidget,
    );
  });
}
