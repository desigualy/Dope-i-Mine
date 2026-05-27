import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dope_i_mine/app/theme/color_tokens.dart';
import 'package:dope_i_mine/presentation/home/home_screen.dart';
import 'package:dope_i_mine/presentation/home/widgets/accessibility_shortcuts_card.dart';
import 'package:dope_i_mine/presentation/home/widgets/body_double_invites_card.dart';
import 'package:dope_i_mine/presentation/home/widgets/caregiver_card.dart';
import 'package:dope_i_mine/presentation/home/widgets/notifications_summary_card.dart';

void main() {
  testWidgets('home restores menu layout without duplicate feature entries',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('home-avatar-v4-rive')),
        findsOneWidget);
    expect(find.text('Hi there!'), findsOneWidget);
    expect(find.text('Ready to tackle your day?'), findsOneWidget);

    expect(find.byKey(const ValueKey<String>('home-menu-task-action')),
        findsOneWidget);
    expect(find.text('Start from something friendly'), findsOneWidget);
    expect(
      find.text('Choose a template, then remix it until it fits.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey<String>('home-today-summary')),
        findsOneWidget);

    expect(find.byKey(const ValueKey<String>('home-menu-my-avatar')),
        findsOneWidget);
    expect(find.text('My avatar'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('home-menu-body-double')),
        findsOneWidget);
    expect(find.text('Body double'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('home-menu-routines')),
        findsOneWidget);
    expect(find.text('My routines'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('home-menu-progress')),
        findsOneWidget);
    expect(find.text('My progress'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('home-menu-caregiver')),
        findsOneWidget);
    expect(find.text('Caregiver support'), findsOneWidget);

    expect(find.byKey(const ValueKey<String>('home-secondary-notifications')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('home-secondary-sync')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('home-secondary-accessibility')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('home-secondary-voice')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('home-secondary-feedback')),
        findsOneWidget);

    expect(find.text('Body-double'), findsNothing);
    expect(find.byKey(const ValueKey<String>('home-support-body-double')),
        findsNothing);
    expect(find.byKey(const ValueKey<String>('home-support-caregiver')),
        findsNothing);
    expect(find.byType(CaregiverCard), findsNothing);
    expect(find.byType(BodyDoubleInvitesCard), findsNothing);
    expect(find.byType(NotificationsSummaryCard), findsNothing);
    expect(find.byType(AccessibilityShortcutsCard), findsNothing);
  });

  testWidgets('secondary shortcuts keep readable dark-mode contrast',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData.dark(),
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final notificationsChip = tester.widget<ActionChip>(
      find.descendant(
        of: find.byKey(const ValueKey<String>('home-secondary-notifications')),
        matching: find.byType(ActionChip),
      ),
    );
    final icon = notificationsChip.avatar! as Icon;

    expect(notificationsChip.backgroundColor, ColorTokens.homeIconWell);
    expect(notificationsChip.labelStyle?.color, ColorTokens.homeSurface);
    expect(icon.color, ColorTokens.homeSurface);
  });

  testWidgets('home does not overflow on compact phones', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
