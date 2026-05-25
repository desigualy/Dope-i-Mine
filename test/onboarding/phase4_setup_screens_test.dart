import 'package:dope_i_mine/domain/onboarding/onboarding_state.dart';
import 'package:dope_i_mine/presentation/onboarding/onboarding_accessibility_setup_screen.dart';
import 'package:dope_i_mine/presentation/onboarding/onboarding_body_double_setup_screen.dart';
import 'package:dope_i_mine/presentation/onboarding/onboarding_controller.dart';
import 'package:dope_i_mine/presentation/onboarding/onboarding_first_task_prompt_screen.dart';
import 'package:dope_i_mine/presentation/onboarding/onboarding_notification_setup_screen.dart';
import 'package:dope_i_mine/presentation/onboarding/onboarding_role_setup_screen.dart';
import 'package:dope_i_mine/presentation/onboarding/onboarding_summary_screen.dart';
import 'package:dope_i_mine/presentation/onboarding/onboarding_voice_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('role setup screen renders plain-language role options',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
          child: MaterialApp(home: OnboardingRoleSetupScreen())),
    );

    expect(find.text('Who is using the app?'), findsOneWidget);
    expect(find.text('I am using this for myself'), findsOneWidget);
    expect(find.text('I support someone else'), findsOneWidget);
    expect(find.text('Someone supports me'), findsOneWidget);
    expect(find.text('Both apply to me'), findsOneWidget);
  });

  testWidgets('voice setup screen renders required controls', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
          child: MaterialApp(home: OnboardingVoiceSetupScreen())),
    );

    expect(find.text('You can use your voice to add tasks.'), findsOneWidget);
    expect(
        find.text('You can ask the app to read steps aloud.'), findsOneWidget);
    expect(find.text('You can stop listening or speaking at any time.'),
        findsOneWidget);
    expect(find.text('Open voice test panel'), findsOneWidget);
  });

  testWidgets('notification setup screen renders reminders and side quests',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: OnboardingNotificationSetupScreen()),
      ),
    );

    expect(find.text('Task and routine reminders'), findsOneWidget);
    expect(find.text('Body-double invites and matches'), findsOneWidget);
    expect(find.text('Side quest prompts'), findsOneWidget);
  });

  testWidgets('accessibility setup screen renders sensory controls',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: OnboardingAccessibilitySetupScreen()),
      ),
    );

    expect(find.text('Large text'), findsOneWidget);
    expect(find.text('Reduced motion'), findsOneWidget);
    expect(find.text('Sensory-friendly colours'), findsOneWidget);
    expect(find.text('Voice-first mode'), findsOneWidget);
  });

  testWidgets('body-double setup screen renders safety copy', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: OnboardingBodyDoubleSetupScreen()),
      ),
    );

    expect(find.text('Dope-i support session'), findsOneWidget);
    expect(find.text('Known-person body double'), findsOneWidget);
    expect(find.text('Random body double'), findsOneWidget);
    expect(find.text('You can leave at any time.'), findsOneWidget);
    expect(find.text('You can report a participant.'), findsOneWidget);
  });

  testWidgets('first task prompt is optional', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: OnboardingFirstTaskPromptScreen()),
      ),
    );

    expect(find.text('Want to start with one small thing?'), findsOneWidget);
    expect(find.text('Create your first task'), findsWidgets);
    expect(find.text('Skip and review setup'), findsOneWidget);
  });

  testWidgets('setup summary renders edit actions for phase 4 choices',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/summary',
      routes: <RouteBase>[
        GoRoute(
          path: '/summary',
          builder: (_, __) => const OnboardingSummaryScreen(),
        ),
        GoRoute(
          path: '/onboarding/phase4/voice',
          builder: (_, __) => const Text('voice edit'),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pump();

    expect(find.text('Setup summary'), findsOneWidget);
    expect(find.text('Role choice'), findsOneWidget);
    expect(find.text('Voice choice'), findsOneWidget);
    expect(find.text('Notification choice'), findsOneWidget);
    expect(find.text('Accessibility and sensory choices'), findsOneWidget);
    expect(find.text('Side quest choice'), findsOneWidget);
    expect(find.text('Body-double preference'), findsOneWidget);
    expect(find.text('First task choice'), findsOneWidget);
    expect(find.text('Edit'), findsWidgets);
  });

  test('setup choices persist after controller reload', () async {
    final first = ProviderContainer();
    addTearDown(first.dispose);
    final controller = first.read(onboardingControllerProvider.notifier)
      ..setRole(OnboardingRole.both)
      ..setVoiceEnabled(false)
      ..setNotificationsEnabled(true)
      ..setLargeText(true)
      ..setReducedMotion(true)
      ..setSideQuestsEnabled(true)
      ..setBodyDoubleEnabled(true);
    await controller.flushPersistenceForTest();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('phase4_onboarding.role'), 'both');

    final second = ProviderContainer();
    addTearDown(second.dispose);
    second.read(onboardingControllerProvider);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final state = second.read(onboardingControllerProvider);
    expect(state.role, OnboardingRole.both);
    expect(state.voiceEnabled, isFalse);
    expect(state.notificationsEnabled, isTrue);
    expect(state.largeText, isTrue);
    expect(state.reducedAnimation, isTrue);
    expect(state.sideQuestsEnabled, isTrue);
    expect(state.bodyDoubleEnabled, isTrue);
  });
}
