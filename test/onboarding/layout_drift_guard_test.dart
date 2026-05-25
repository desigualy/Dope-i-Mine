import 'dart:io';

import 'package:dope_i_mine/presentation/branding/dope_i_intro_screen.dart';
import 'package:dope_i_mine/presentation/onboarding/age_band_screen.dart';
import 'package:dope_i_mine/presentation/onboarding/onboarding_summary_screen.dart';
import 'package:dope_i_mine/presentation/onboarding/widgets/onboarding_page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('legacy onboarding pages do not show wizard progress',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: DopeIIntroScreen()),
      ),
    );

    expect(find.byType(OnboardingPageScaffold), findsOneWidget);
    expect(find.textContaining('Step '), findsNothing);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: AgeBandScreen()),
      ),
    );

    expect(find.byType(OnboardingPageScaffold), findsOneWidget);
    expect(find.textContaining('Step '), findsNothing);
  });

  testWidgets('onboarding summary remains concise', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: OnboardingSummaryScreen()),
      ),
    );

    expect(find.text('Setup summary'), findsOneWidget);
    expect(find.textContaining('Step 13 of 13'), findsNothing);
    expect(find.text('Pronunciation'), findsOneWidget);
    expect(find.text('Support style'), findsOneWidget);
    expect(find.text('Voice choice'), findsOneWidget);
    expect(find.text('Accessibility basics'), findsOneWidget);
    expect(find.text('Optional setup'), findsOneWidget);
    expect(find.text('First task choice'), findsNothing);
    expect(find.text('Body-double preference'), findsNothing);
  });

  test('app router does not expose duplicate phase4 onboarding routes', () {
    final routerSource = File('lib/app/router.dart').readAsStringSync();

    expect(routerSource, isNot(contains('/onboarding/phase4/voice')));
    expect(routerSource, isNot(contains('/onboarding/phase4/accessibility')));
    expect(routerSource, isNot(contains('/onboarding/phase4/summary')));
    expect(routerSource, contains('/settings/setup'));
  });

  test('home screen does not instantiate every optional support card', () {
    final homeSource =
        File('lib/presentation/home/home_screen.dart').readAsStringSync();

    expect(homeSource, isNot(contains('CaregiverCard(')));
    expect(homeSource, isNot(contains('BodyDoubleInvitesCard(')));
    expect(homeSource, isNot(contains('NotificationsSummaryCard(')));
    expect(homeSource, isNot(contains('AccessibilityShortcutsCard(')));
    expect(homeSource, contains('home-support-body-double'));
    expect(homeSource, contains('home-support-caregiver'));
    expect(homeSource, contains('home-support-notifications'));
  });
}
