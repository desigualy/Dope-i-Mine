import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dope_i_mine/presentation/home/widgets/caregiver_card.dart';
import 'package:dope_i_mine/presentation/home/widgets/body_double_invites_card.dart';
import 'package:dope_i_mine/presentation/home/widgets/notifications_summary_card.dart';
import 'package:dope_i_mine/presentation/home/widgets/accessibility_shortcuts_card.dart';

void main() {
  testWidgets('Home cards render', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ListView(children: const [
          CaregiverCard(),
          BodyDoubleInvitesCard(),
          NotificationsSummaryCard(),
          AccessibilityShortcutsCard(),
        ]),
      ),
    ));

    expect(find.text('Caregiver'), findsOneWidget);
    expect(find.text('Body-double'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Accessibility'), findsOneWidget);
  });
}
