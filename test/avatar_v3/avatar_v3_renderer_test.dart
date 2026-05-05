import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dope_i_mine/domain/avatar_v3/avatar_v3_migration.dart';
import 'package:dope_i_mine/presentation/avatar_v3/avatar_v3_renderer.dart';

void main() {
  testWidgets('Avatar V3 renderer is the active renderer', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AvatarV3Renderer(
            profile: AvatarV3Migration.defaultReferenceProfile,
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey<String>('avatar-v3-renderer')), findsOneWidget);
  });
}
