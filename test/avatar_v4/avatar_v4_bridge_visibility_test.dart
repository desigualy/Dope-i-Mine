import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dope_i_mine/presentation/avatar/avatar_engine_bridge.dart';

void main() {
  testWidgets('Avatar engine bridge uses Avatar V4 fallback surface', (tester) async {
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
      find.byKey(const ValueKey<String>('avatar-v4-engine-bridge')),
      findsOneWidget,
    );

    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('avatar-v4-missing-rig-diagnostic')),
      findsOneWidget,
    );
  });
}
