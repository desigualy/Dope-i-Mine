import 'package:dope_i_mine/presentation/home/home_screen.dart';
import 'package:dope_i_mine/presentation/user_avatar/user_avatar_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home page exposes the user avatar creation and editing suite',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Your avatar studio'), findsOneWidget);
    expect(find.byType(UserAvatarRenderer), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('create-user-avatar-button')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('edit-user-avatar-button')),
        findsOneWidget);
    expect(find.text('Display name'), findsOneWidget);
    expect(find.text('Avatar mode'), findsOneWidget);
    expect(find.text('Looks like me'), findsOneWidget);
    expect(find.text('Inspired by me'), findsOneWidget);
    expect(find.text('Private / abstract'), findsOneWidget);
    expect(find.text('Fantasy version'), findsNothing);
  });

  testWidgets('home avatar studio edits and switches to privacy-first mode',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(
      find.byKey(const ValueKey<String>('avatar-name-field')),
      'Nova',
    );
    await tester.pump();

    expect(find.text('Nova'), findsWidgets);

    final privateAbstractChip = find.ancestor(
      of: find.text('Private / abstract'),
      matching: find.byType(ChoiceChip),
    );
    await tester.ensureVisible(privateAbstractChip);
    await tester.pump();
    await tester.tap(privateAbstractChip);
    await tester.pump();

    expect(find.text('Private / abstract avatar'), findsOneWidget);
    expect(find.text('Portrait identity and body'), findsNothing);
    expect(
      find.byKey(
        const ValueKey<String>(
          'user-avatar-layer-assets/user_avatar/abstract/orbs/calm.png',
        ),
      ),
      findsOneWidget,
    );
  });
}
