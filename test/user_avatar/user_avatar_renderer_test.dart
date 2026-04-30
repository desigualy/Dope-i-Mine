import 'package:dope_i_mine/domain/user_avatar/user_avatar_profile.dart';
import 'package:dope_i_mine/presentation/user_avatar/user_avatar_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders layered soft portrait avatar with fallback base',
      (tester) async {
    const profile = UserAvatarProfile(
      skinTone: 'brown',
      hairType: 'locs',
      hairStyle: 'short',
      hairColor: 'black',
      accessibilityItems: <String>['sensory_headphones'],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: UserAvatarRenderer(profile: profile),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('user-avatar-fallback-base')),
      findsOneWidget,
    );
    expect(find.byType(Image), findsWidgets);
    expect(
      find.byKey(
        const ValueKey<String>(
          'user-avatar-layer-assets/user_avatar/accessibility/sensory/sensory_headphones.png',
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('fallback portrait supports cultural and disability markers',
      (tester) async {
    const profile = UserAvatarProfile(
      skinTone: 'deep_brown',
      hairType: 'coily',
      hairStyle: 'afro',
      hairColor: 'black',
      culturalItems: <String>['hijab'],
      accessibilityItems: <String>['glasses', 'hearing_aids', 'wheelchair'],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: UserAvatarRenderer(profile: profile),
        ),
      ),
    );
    expect(
      find.bySemanticsLabel('Soft illustrated portrait user avatar'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey<String>('user-avatar-fallback-base')),
        findsOneWidget);
  });

  testWidgets('renders privacy-first abstract avatar layers', (tester) async {
    const profile = UserAvatarProfile.privateAbstract(moodStyle: 'playful');

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: UserAvatarRenderer(profile: profile),
        ),
      ),
    );

    expect(
      find.byKey(
        const ValueKey<String>(
          'user-avatar-layer-assets/user_avatar/abstract/orbs/playful.png',
        ),
      ),
      findsOneWidget,
    );
  });
}
