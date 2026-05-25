import 'package:dope_i_mine/presentation/onboarding/onboarding_accessibility_setup_screen.dart';
import 'package:dope_i_mine/presentation/onboarding/onboarding_body_double_setup_screen.dart';
import 'package:dope_i_mine/presentation/onboarding/onboarding_first_task_prompt_screen.dart';
import 'package:dope_i_mine/presentation/onboarding/onboarding_notification_setup_screen.dart';
import 'package:dope_i_mine/presentation/onboarding/onboarding_role_setup_screen.dart';
import 'package:dope_i_mine/presentation/onboarding/onboarding_summary_screen.dart';
import 'package:dope_i_mine/presentation/onboarding/onboarding_voice_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('first beta setup reaches summary with editable choices',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final router = GoRouter(
      initialLocation: '/role',
      routes: <RouteBase>[
        GoRoute(
          path: '/role',
          builder: (_, __) => const OnboardingRoleSetupScreen(),
        ),
        GoRoute(
          path: '/onboarding/phase4/voice',
          builder: (_, __) => const OnboardingVoiceSetupScreen(),
        ),
        GoRoute(
          path: '/onboarding/phase4/notifications',
          builder: (_, __) => const OnboardingNotificationSetupScreen(),
        ),
        GoRoute(
          path: '/onboarding/phase4/accessibility',
          builder: (_, __) => const OnboardingAccessibilitySetupScreen(),
        ),
        GoRoute(
          path: '/onboarding/phase4/body-double',
          builder: (_, __) => const OnboardingBodyDoubleSetupScreen(),
        ),
        GoRoute(
          path: '/onboarding/phase4/first-task',
          builder: (_, __) => const OnboardingFirstTaskPromptScreen(),
        ),
        GoRoute(
          path: '/onboarding/summary',
          builder: (_, __) => const OnboardingSummaryScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip and review setup'));
    await tester.pumpAndSettle();

    expect(find.text('Setup summary'), findsOneWidget);
    expect(find.text('Role choice'), findsOneWidget);
    expect(find.text('Voice choice'), findsOneWidget);
    expect(find.text('Notification choice'), findsOneWidget);
    expect(find.text('Accessibility and sensory choices'), findsOneWidget);
    expect(find.text('Body-double preference'), findsOneWidget);
  });
}
