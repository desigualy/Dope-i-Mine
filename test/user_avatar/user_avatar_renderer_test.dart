import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dope_i_mine/domain/user_avatar/user_avatar_profile.dart';
import 'package:dope_i_mine/presentation/user_avatar/user_avatar_renderer.dart';

void main() {
  testWidgets('user avatar renderer delegates to Avatar V4 bridge', (tester) async {
    const profile = UserAvatarProfile(
      avatarType: UserAvatarProfile.avatarTypeLooksLikeMe,
      skinTone: 'tan',
      hairType: 'curly_afro',
      hairStyle: 'long_ringlet_afro',
      hairColor: 'copper',
      bodyShape: 'average',
      accessibilityItems: <String>['glasses'],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: UserAvatarRenderer(profile: profile),
        ),
      ),
    );

    expect(find.byKey(const ValueKey<String>('avatar-v4-engine-bridge')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('user-avatar-fallback-base')), findsNothing);
  });

  testWidgets('privacy-first avatar still uses Avatar V4 bridge', (tester) async {
    const profile = UserAvatarProfile(
      avatarType: UserAvatarProfile.avatarTypePrivateAbstract,
      skinTone: 'medium',
      hairType: 'wavy',
      hairStyle: 'medium_wavy',
      hairColor: 'brown',
      bodyShape: 'average',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: UserAvatarRenderer(profile: profile),
        ),
      ),
    );

    expect(find.byKey(const ValueKey<String>('avatar-v4-engine-bridge')), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey<String>(
          'user-avatar-layer-assets/user_avatar/abstract/orbs/playful.png',
        ),
      ),
      findsNothing,
    );
  });
}
