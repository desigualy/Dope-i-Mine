import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dope_i_mine/presentation/home/home_screen.dart';
import 'package:dope_i_mine/presentation/home/widgets/accessibility_shortcuts_card.dart';
import 'package:dope_i_mine/presentation/home/widgets/body_double_invites_card.dart';
import 'package:dope_i_mine/presentation/home/widgets/caregiver_card.dart';
import 'package:dope_i_mine/presentation/home/widgets/notifications_summary_card.dart';

void main() {
  testWidgets('home keeps primary task action and compact support access',
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

    expect(find.text('Start with one small step'), findsOneWidget);
    expect(find.text('Start a task'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('home-support-body-double')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('home-support-caregiver')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('home-support-notifications')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('home-support-accessibility')),
        findsOneWidget);
    expect(find.byType(CaregiverCard), findsNothing);
    expect(find.byType(BodyDoubleInvitesCard), findsNothing);
    expect(find.byType(NotificationsSummaryCard), findsNothing);
    expect(find.byType(AccessibilityShortcutsCard), findsNothing);
  });
}
