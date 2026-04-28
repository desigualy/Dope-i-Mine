import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:dope_i_mine/data/repositories/auth_repository_impl.dart';
import 'package:dope_i_mine/data/repositories/companion_repository_impl.dart';
import 'package:dope_i_mine/data/repositories/profile_repository_impl.dart';
import 'package:dope_i_mine/data/repositories/voice_settings_repository_impl.dart';
import 'package:dope_i_mine/app/onboarding_gate_screen.dart';
import 'package:dope_i_mine/domain/auth/auth_user.dart';
import 'package:dope_i_mine/domain/branding/pronunciation_option.dart';
import 'package:dope_i_mine/domain/companion/avatar_config_model.dart';
import 'package:dope_i_mine/domain/companion/companion_model.dart';
import 'package:dope_i_mine/domain/profile/sensory_settings_model.dart';
import 'package:dope_i_mine/domain/profile/user_profile_model.dart';
import 'package:dope_i_mine/domain/tasks/task_state_snapshot.dart';
import 'package:dope_i_mine/domain/voice/voice_settings_model.dart';
import 'package:dope_i_mine/presentation/auth/login_screen.dart';
import 'package:dope_i_mine/core/widgets/async_action_button.dart';
import 'package:dope_i_mine/presentation/branding/dope_i_intro_screen.dart';
import 'package:dope_i_mine/presentation/branding/pronunciation_setup_screen.dart';
import 'package:dope_i_mine/presentation/onboarding/age_band_screen.dart';
import 'package:dope_i_mine/presentation/onboarding/assistant_name_screen.dart';
import 'package:dope_i_mine/presentation/onboarding/accessibility_screen.dart';
import 'package:dope_i_mine/presentation/onboarding/mode_selection_screen.dart';
import 'package:dope_i_mine/presentation/onboarding/onboarding_summary_screen.dart';
import 'package:dope_i_mine/presentation/onboarding/permissions_screen.dart';
import 'package:dope_i_mine/presentation/onboarding/sensory_preferences_screen.dart';
import 'package:dope_i_mine/presentation/onboarding/voice_preferences_screen.dart';
import 'package:dope_i_mine/presentation/onboarding/voice_setup_screen.dart';
import 'package:dope_i_mine/presentation/onboarding/avatar_setup_screen.dart';
import 'package:dope_i_mine/presentation/home/home_screen.dart';
import 'package:dope_i_mine/providers.dart';

class _FakeAuthRepository implements AuthRepositoryImpl {
  _FakeAuthRepository({this.persistCurrentUserOnSignIn = true});

  AuthUser? user;
  final bool persistCurrentUserOnSignIn;

  @override
  Future<AuthUser?> signIn(
      {required String email, required String password}) async {
    const signedInUser = AuthUser(id: 'tester', email: 'tester@example.com');
    if (persistCurrentUserOnSignIn) {
      user = signedInUser;
    }
    return signedInUser;
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthUser?> signUp(
      {required String email, required String password}) async {
    const signedUpUser = AuthUser(id: 'tester', email: 'tester@example.com');
    user = signedUpUser;
    return signedUpUser;
  }

  @override
  AuthUser? getCurrentUser() => user;
}

class _FakeCompanionRepository implements CompanionRepositoryImpl {
  @override
  Future<List<CompanionModel>> getCompanions() async {
    return const <CompanionModel>[
      CompanionModel(id: 'companion1', name: 'Buddy', style: 'Calm orb'),
    ];
  }

  @override
  Future<void> saveAvatarConfig({
    required String userId,
    required AvatarConfigModel config,
  }) async {}

  @override
  Future<AvatarConfigModel?> getAvatarConfig(String userId) async {
    return const AvatarConfigModel(
      avatarStyle: 'fox',
      avatarPalette: 'bright',
      accessoryConfig: <String, dynamic>{},
    );
  }

  @override
  Future<void> setActiveCompanion({
    required String userId,
    required String companionId,
  }) async {}
}

class _FakeProfileRepository implements ProfileRepositoryImpl {
  _FakeProfileRepository({
    this.onboardingComplete = false,
    this.throwOnCompletionCheck = false,
  });

  bool onboardingComplete;
  final bool throwOnCompletionCheck;

  @override
  Future<void> ensureProfileExists(
      {required String userId, String? email}) async {}

  @override
  Future<void> setOnboardingCompleted({
    required String userId,
    String? email,
    required bool completed,
  }) async {
    onboardingComplete = completed;
  }

  @override
  Future<void> saveOnboardingProfile({
    required String userId,
    required AgeBand ageBand,
    required SupportMode mode,
    required String assistantDisplayName,
    required PronunciationOption pronunciation,
    required bool voiceEnabled,
    required bool reducedAnimation,
    required bool largeText,
    required bool soundEnabled,
    bool softColors = true,
    String praiseLevel = 'medium',
    bool iconMode = false,
    bool reduceSurprises = true,
  }) async {
    onboardingComplete = true;
  }

  @override
  Future<UserProfileModel?> getProfile(String userId) async => null;

  @override
  Future<bool> isOnboardingComplete(String userId) async {
    if (throwOnCompletionCheck) {
      throw StateError('Cannot read onboarding status');
    }
    return onboardingComplete;
  }

  @override
  Future<SensorySettingsModel?> getSensorySettings(String userId) async => null;
}

GoRouter _buildHomeGateRouter() {
  return GoRouter(
    initialLocation: '/home',
    routes: <RouteBase>[
      GoRoute(
        path: '/home',
        builder: (_, __) => const OnboardingGateScreen(child: HomeScreen()),
      ),
      GoRoute(
        path: '/branding/intro',
        builder: (_, __) => const DopeIIntroScreen(returnToSummary: false),
      ),
    ],
  );
}

class _FakeVoiceSettingsRepository implements VoiceSettingsRepositoryImpl {
  @override
  Future<List<Map<String, dynamic>>> getVoiceProfiles() async {
    return const <Map<String, dynamic>>[
      <String, dynamic>{'id': 'voice1', 'label': 'Test voice'},
    ];
  }

  @override
  Future<void> save({
    required String userId,
    required VoiceSettingsModel settings,
  }) async {}

  @override
  Future<VoiceSettingsModel?> getSettings(String userId) async => null;
}

GoRouter _buildOnboardingRouter() {
  return GoRouter(
    initialLocation: '/branding/intro',
    routes: <RouteBase>[
      GoRoute(
        path: '/branding/intro',
        builder: (_, __) => const DopeIIntroScreen(returnToSummary: false),
      ),
      GoRoute(
        path: '/branding/pronunciation',
        builder: (_, __) =>
            const PronunciationSetupScreen(returnToSummary: false),
      ),
      GoRoute(
        path: '/onboarding/age-band',
        builder: (_, __) => const AgeBandScreen(returnToSummary: false),
      ),
      GoRoute(
        path: '/onboarding/assistant-name',
        builder: (_, __) => const AssistantNameScreen(returnToSummary: false),
      ),
      GoRoute(
        path: '/onboarding/mode',
        builder: (_, __) => const ModeSelectionScreen(returnToSummary: false),
      ),
      GoRoute(
        path: '/onboarding/accessibility',
        builder: (_, __) => const AccessibilityScreen(returnToSummary: false),
      ),
      GoRoute(
        path: '/onboarding/sensory',
        builder: (_, __) =>
            const SensoryPreferencesScreen(returnToSummary: false),
      ),
      GoRoute(
        path: '/onboarding/permissions',
        builder: (_, __) => const PermissionsScreen(returnToSummary: false),
      ),
      GoRoute(
        path: '/onboarding/voice',
        builder: (_, __) =>
            const VoicePreferencesScreen(returnToSummary: false),
      ),
      GoRoute(
        path: '/onboarding/voice-setup',
        builder: (_, __) => const VoiceSetupScreen(returnToSummary: false),
      ),
      GoRoute(
        path: '/onboarding/avatar',
        builder: (_, __) => const AvatarSetupScreen(returnToSummary: false),
      ),
      GoRoute(
        path: '/onboarding/summary',
        builder: (_, __) => const OnboardingSummaryScreen(),
      ),
    ],
  );
}

GoRouter _buildLoginOnboardingRouter() {
  return GoRouter(
    initialLocation: '/login',
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const OnboardingGateScreen(child: HomeScreen()),
      ),
      GoRoute(
        path: '/branding/intro',
        builder: (_, __) => const DopeIIntroScreen(returnToSummary: false),
      ),
      GoRoute(
        path: '/branding/pronunciation',
        builder: (_, __) =>
            const PronunciationSetupScreen(returnToSummary: false),
      ),
      GoRoute(
        path: '/onboarding/age-band',
        builder: (_, __) => const AgeBandScreen(returnToSummary: false),
      ),
      GoRoute(
        path: '/onboarding/assistant-name',
        builder: (_, __) => const AssistantNameScreen(returnToSummary: false),
      ),
      GoRoute(
        path: '/onboarding/mode',
        builder: (_, __) => const ModeSelectionScreen(returnToSummary: false),
      ),
      GoRoute(
        path: '/onboarding/accessibility',
        builder: (_, __) => const AccessibilityScreen(returnToSummary: false),
      ),
      GoRoute(
        path: '/onboarding/sensory',
        builder: (_, __) =>
            const SensoryPreferencesScreen(returnToSummary: false),
      ),
      GoRoute(
        path: '/onboarding/permissions',
        builder: (_, __) => const PermissionsScreen(returnToSummary: false),
      ),
      GoRoute(
        path: '/onboarding/voice',
        builder: (_, __) =>
            const VoicePreferencesScreen(returnToSummary: false),
      ),
      GoRoute(
        path: '/onboarding/voice-setup',
        builder: (_, __) => const VoiceSetupScreen(returnToSummary: false),
      ),
      GoRoute(
        path: '/onboarding/avatar',
        builder: (_, __) => const AvatarSetupScreen(returnToSummary: false),
      ),
      GoRoute(
        path: '/onboarding/summary',
        builder: (_, __) => const OnboardingSummaryScreen(),
      ),
    ],
  );
}

void main() {
  testWidgets('onboarding wizard advances through every step',
      (WidgetTester tester) async {
    final fakeAuthRepository = _FakeAuthRepository()
      ..user = const AuthUser(id: 'tester', email: 'tester@example.com');
    final fakeCompanionRepository = _FakeCompanionRepository();
    final fakeVoiceSettingsRepository = _FakeVoiceSettingsRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          companionRepositoryProvider
              .overrideWithValue(fakeCompanionRepository),
          voiceSettingsRepositoryProvider
              .overrideWithValue(fakeVoiceSettingsRepository),
        ],
        child: MaterialApp.router(
          routerConfig: _buildOnboardingRouter(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Meet Dope-i'), findsOneWidget);
    expect(find.text('Step 1 of 12'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.text('How should Dope-i sound?'), findsOneWidget);
    expect(find.text('Step 2 of 12'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Choose age band'), findsOneWidget);
    expect(find.text('Step 3 of 12'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Name your assistant'), findsOneWidget);
    expect(find.text('Step 4 of 12'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Choose support mode'), findsOneWidget);
    expect(find.text('Step 5 of 12'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Accessibility & comfort'), findsOneWidget);
    expect(find.text('Step 6 of 12'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Sensory preferences'), findsOneWidget);
    expect(find.text('Step 7 of 12'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Permissions & device checks'), findsOneWidget);
    expect(find.text('Step 8 of 12'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Voice setup'), findsOneWidget);
    expect(find.text('Step 10 of 12'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Voice preferences'), findsOneWidget);
    expect(find.text('Step 9 of 12'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Voice setup'), findsOneWidget);
    expect(find.text('Step 10 of 12'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Companion & avatar'), findsOneWidget);
    expect(find.text('Step 11 of 12'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Save and continue'));
    await tester.pumpAndSettle();

    expect(find.text('Summary'), findsOneWidget);
    expect(find.text('Step 12 of 12'), findsOneWidget);
    expect(find.text('Avatar'), findsOneWidget);
    expect(find.text('fox, bright'), findsOneWidget);
  });

  testWidgets('login to onboarding summary full setup',
      (WidgetTester tester) async {
    final fakeAuthRepository = _FakeAuthRepository();
    final fakeProfileRepository = _FakeProfileRepository();
    final fakeCompanionRepository = _FakeCompanionRepository();
    final fakeVoiceSettingsRepository = _FakeVoiceSettingsRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
          companionRepositoryProvider
              .overrideWithValue(fakeCompanionRepository),
          voiceSettingsRepositoryProvider
              .overrideWithValue(fakeVoiceSettingsRepository),
        ],
        child: MaterialApp.router(
          routerConfig: _buildLoginOnboardingRouter(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Log in'), findsNWidgets(2));
    await tester.enterText(find.byType(TextField).first, 'tester@example.com');
    await tester.enterText(find.byType(TextField).last, 'password123');
    await tester.tap(find.widgetWithText(AsyncActionButton, 'Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Meet Dope-i'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.text('How should Dope-i sound?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Choose age band'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Name your assistant'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Choose support mode'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Accessibility & comfort'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Sensory preferences'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Permissions & device checks'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Voice setup'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Voice preferences'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Voice setup'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Companion & avatar'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Save and continue'));
    await tester.pumpAndSettle();

    expect(find.text('Summary'), findsOneWidget);
    expect(find.text('Step 12 of 12'), findsOneWidget);
  });

  testWidgets('login starts onboarding instead of being redirected away',
      (WidgetTester tester) async {
    final fakeAuthRepository = _FakeAuthRepository();
    final fakeProfileRepository = _FakeProfileRepository();
    final fakeCompanionRepository = _FakeCompanionRepository();
    final fakeVoiceSettingsRepository = _FakeVoiceSettingsRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
          companionRepositoryProvider
              .overrideWithValue(fakeCompanionRepository),
          voiceSettingsRepositoryProvider
              .overrideWithValue(fakeVoiceSettingsRepository),
        ],
        child: MaterialApp.router(
          routerConfig: _buildLoginOnboardingRouter(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Log in'), findsNWidgets(2));
    await tester.enterText(find.byType(TextField).first, 'tester@example.com');
    await tester.enterText(find.byType(TextField).last, 'password123');
    await tester.tap(find.widgetWithText(AsyncActionButton, 'Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Meet Dope-i'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.text('How should Dope-i sound?'), findsOneWidget);
  });

  testWidgets(
      'already authenticated user on login is redirected to onboarding when incomplete',
      (WidgetTester tester) async {
    final fakeAuthRepository = _FakeAuthRepository()
      ..user = const AuthUser(id: 'tester', email: 'tester@example.com');
    final fakeProfileRepository =
        _FakeProfileRepository(onboardingComplete: false);
    final fakeCompanionRepository = _FakeCompanionRepository();
    final fakeVoiceSettingsRepository = _FakeVoiceSettingsRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
          companionRepositoryProvider
              .overrideWithValue(fakeCompanionRepository),
          voiceSettingsRepositoryProvider
              .overrideWithValue(fakeVoiceSettingsRepository),
        ],
        child: MaterialApp.router(
          routerConfig: _buildLoginOnboardingRouter(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Meet Dope-i'), findsOneWidget);
    expect(find.text('Log in'), findsNothing);
  });

  testWidgets(
      'already authenticated user on login is redirected to home when complete',
      (WidgetTester tester) async {
    final fakeAuthRepository = _FakeAuthRepository()
      ..user = const AuthUser(id: 'tester', email: 'tester@example.com');
    final fakeProfileRepository =
        _FakeProfileRepository(onboardingComplete: true);
    final fakeCompanionRepository = _FakeCompanionRepository();
    final fakeVoiceSettingsRepository = _FakeVoiceSettingsRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
          companionRepositoryProvider
              .overrideWithValue(fakeCompanionRepository),
          voiceSettingsRepositoryProvider
              .overrideWithValue(fakeVoiceSettingsRepository),
        ],
        child: MaterialApp.router(
          routerConfig: _buildLoginOnboardingRouter(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('What do you need to do?'), findsOneWidget);
    expect(find.text('Log in'), findsNothing);
  });

  testWidgets(
      'login can still route to onboarding when sign-in returns a user before currentUser is readable',
      (WidgetTester tester) async {
    final fakeAuthRepository =
        _FakeAuthRepository(persistCurrentUserOnSignIn: false);
    final fakeProfileRepository = _FakeProfileRepository();
    final fakeCompanionRepository = _FakeCompanionRepository();
    final fakeVoiceSettingsRepository = _FakeVoiceSettingsRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
          companionRepositoryProvider
              .overrideWithValue(fakeCompanionRepository),
          voiceSettingsRepositoryProvider
              .overrideWithValue(fakeVoiceSettingsRepository),
        ],
        child: MaterialApp.router(
          routerConfig: _buildLoginOnboardingRouter(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'tester@example.com');
    await tester.enterText(find.byType(TextField).last, 'password123');
    await tester.tap(find.widgetWithText(AsyncActionButton, 'Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Meet Dope-i'), findsOneWidget);
    expect(find.text('What do you need to do?'), findsNothing);
  });

  testWidgets('login sends users with completed onboarding to home',
      (WidgetTester tester) async {
    final fakeAuthRepository = _FakeAuthRepository();
    final fakeProfileRepository =
        _FakeProfileRepository(onboardingComplete: true);
    final fakeCompanionRepository = _FakeCompanionRepository();
    final fakeVoiceSettingsRepository = _FakeVoiceSettingsRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
          companionRepositoryProvider
              .overrideWithValue(fakeCompanionRepository),
          voiceSettingsRepositoryProvider
              .overrideWithValue(fakeVoiceSettingsRepository),
        ],
        child: MaterialApp.router(
          routerConfig: _buildLoginOnboardingRouter(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'tester@example.com');
    await tester.enterText(find.byType(TextField).last, 'password123');
    await tester.tap(find.widgetWithText(AsyncActionButton, 'Log in'));
    await tester.pumpAndSettle();

    expect(find.text('What do you need to do?'), findsOneWidget);
    expect(find.text('Meet Dope-i'), findsNothing);
  });

  testWidgets('home gate sends incomplete authenticated users to onboarding',
      (WidgetTester tester) async {
    final fakeAuthRepository = _FakeAuthRepository()
      ..user = const AuthUser(id: 'tester', email: 'tester@example.com');
    final fakeProfileRepository =
        _FakeProfileRepository(onboardingComplete: false);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
        ],
        child: MaterialApp.router(routerConfig: _buildHomeGateRouter()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Meet Dope-i'), findsOneWidget);
  });

  testWidgets('home gate allows complete authenticated users to see home',
      (WidgetTester tester) async {
    final fakeAuthRepository = _FakeAuthRepository()
      ..user = const AuthUser(id: 'tester', email: 'tester@example.com');
    final fakeProfileRepository =
        _FakeProfileRepository(onboardingComplete: true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
        ],
        child: MaterialApp.router(routerConfig: _buildHomeGateRouter()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('What do you need to do?'), findsOneWidget);
  });

  testWidgets(
      'home screen renders content directly; route gate owns onboarding protection',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('What do you need to do?'), findsOneWidget);
    expect(find.text('Meet Dope-i'), findsNothing);
  });

  testWidgets(
      'home gate fails closed to onboarding when completion check throws',
      (WidgetTester tester) async {
    final fakeAuthRepository = _FakeAuthRepository()
      ..user = const AuthUser(id: 'tester', email: 'tester@example.com');
    final fakeProfileRepository = _FakeProfileRepository(
      throwOnCompletionCheck: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
        ],
        child: MaterialApp.router(routerConfig: _buildHomeGateRouter()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Meet Dope-i'), findsOneWidget);
    expect(find.text('What do you need to do?'), findsNothing);
  });

  testWidgets(
      'restart onboarding clears completion on the active runtime backend',
      (WidgetTester tester) async {
    final fakeAuthRepository = _FakeAuthRepository()
      ..user = const AuthUser(id: 'tester', email: 'tester@example.com');
    final fakeProfileRepository =
        _FakeProfileRepository(onboardingComplete: true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
        ],
        child: MaterialApp.router(routerConfig: _buildHomeGateRouter()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('What do you need to do?'), findsOneWidget);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Restart onboarding'));
    await tester.pumpAndSettle();

    expect(fakeProfileRepository.onboardingComplete, isFalse);
    expect(find.text('Meet Dope-i'), findsOneWidget);
  });
}
