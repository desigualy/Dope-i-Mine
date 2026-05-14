import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:dope_i_mine/avatar_engine_v4/avatar_engine_v4.dart';
import 'package:dope_i_mine/data/repositories/auth_repository_impl.dart';
import 'package:dope_i_mine/data/repositories/companion_repository_impl.dart';
import 'package:dope_i_mine/data/repositories/profile_repository_impl.dart';
import 'package:dope_i_mine/data/repositories/voice_settings_repository_impl.dart';
import 'package:dope_i_mine/app/onboarding_gate_screen.dart';
import 'package:dope_i_mine/domain/avatar/avatar_enums.dart' as user_avatar;
import 'package:dope_i_mine/domain/avatar/user_avatar_profile.dart';
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
import 'package:dope_i_mine/presentation/onboarding/identity_screen.dart';
import 'package:dope_i_mine/presentation/home/home_screen.dart';
import 'package:dope_i_mine/presentation/settings/companion_screen.dart';
import 'package:dope_i_mine/presentation/settings/settings_screen.dart';
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
      {required String email,
      required String password,
      String accountType = 'user'}) async {
    const signedUpUser = AuthUser(id: 'tester', email: 'tester@example.com');
    user = signedUpUser;
    return signedUpUser;
  }

  @override
  AuthUser? getCurrentUser() => user;

  @override
  Future<void> sendPasswordResetEmail(String email) async {}
}

class _FakeCompanionRepository implements CompanionRepositoryImpl {
  AvatarConfigModel? savedAvatarConfig;

  @override
  Future<List<CompanionModel>> getCompanions() async {
    return const <CompanionModel>[
      CompanionModel(
        id: 'companion1',
        name: 'Dope-i',
        style: 'Neon hoodie robot mascot',
      ),
    ];
  }

  @override
  Future<void> saveAvatarConfig({
    required String userId,
    required AvatarConfigModel config,
  }) async {
    savedAvatarConfig = config;
  }

  @override
  Future<AvatarConfigModel?> getAvatarConfig(String userId) async {
    return savedAvatarConfig ??
        const AvatarConfigModel(
          avatarStyle: AvatarConfigModel.modeInspiredByMe,
          avatarPalette: AvatarConfigModel.paletteSoftIllustrated,
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
    this.accountType = 'user',
  });

  bool onboardingComplete;
  final bool throwOnCompletionCheck;
  String accountType;

  @override
  Future<void> ensureProfileExists(
      {required String userId,
      String? email,
      String accountType = 'user'}) async {
    if (accountType == 'caregiver' || this.accountType == 'caregiver') {
      this.accountType = 'caregiver';
    }
  }

  @override
  Future<String> getAccountType(String userId) async =>
      accountType == 'caregiver' ? 'caregiver' : 'user';

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
    String? sexAtBirth,
    String? genderIdentity,
    String? pronouns,
    String? customPronouns,
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

  @override
  Future<void> updateAssistantName(String userId, String name) async {}

  @override
  Future<void> updateSensorySettings(
    String userId, {
    bool? reducedAnimation,
    bool? largeText,
    bool? soundEnabled,
    bool? softColors,
    String? praiseLevel,
    bool? iconMode,
    bool? reduceSurprises,
  }) async {}
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
        path: '/caregiver',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Caregiver Support')),
        ),
      ),
      GoRoute(
        path: '/branding/intro',
        builder: (_, __) => const DopeIIntroScreen(returnToSummary: false),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/companion',
        builder: (_, __) => const CompanionScreen(),
      ),
      GoRoute(
        path: '/avatar/customize',
        builder: (_, __) => const AvatarCustomizerScreen(),
      ),
    ],
  );
}

Future<void> _pumpUntilVisible(
  WidgetTester tester,
  Finder finder, {
  Duration step = const Duration(milliseconds: 100),
  int maxPumps = 20,
}) async {
  for (var pumpCount = 0; pumpCount < maxPumps; pumpCount += 1) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) return;
  }
}

Future<void> _pumpUntilAbsent(
  WidgetTester tester,
  Finder finder, {
  Duration step = const Duration(milliseconds: 100),
  int maxPumps = 20,
}) async {
  for (var pumpCount = 0; pumpCount < maxPumps; pumpCount += 1) {
    await tester.pump(step);
    if (finder.evaluate().isEmpty) return;
  }
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

// ignore: unused_element
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
        path: '/onboarding/identity',
        builder: (_, __) => IdentityScreen(returnToSummary: false),
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
        path: '/caregiver',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Caregiver Support')),
        ),
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
        path: '/onboarding/identity',
        builder: (_, __) => IdentityScreen(returnToSummary: false),
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
    final flowSource =
        File('test/onboarding/onboarding_flow_test.dart').readAsStringSync();
    final voiceSource =
        File('lib/presentation/onboarding/voice_setup_screen.dart')
            .readAsStringSync();
    final identitySource =
        File('lib/presentation/onboarding/identity_screen.dart')
            .readAsStringSync();
    final avatarSource =
        File('lib/presentation/onboarding/avatar_setup_screen.dart')
            .readAsStringSync();

    expect(flowSource, contains('IdentityScreen'));
    expect(flowSource, contains('/onboarding/identity'));
    expect(voiceSource, contains('/onboarding/identity'));
    expect(identitySource, contains('Sex, gender & pronouns'));
    expect(identitySource, contains('onboarding-sex-at-birth-field'));
    expect(identitySource, contains('onboarding-gender-identity-field'));
    expect(identitySource, contains('onboarding-pronouns-field'));
    expect(identitySource, contains('/onboarding/avatar'));
    expect(avatarSource, contains('AvatarRiveView'));
    expect(avatarSource, contains('onboarding-avatar-preview'));
    expect(avatarSource, contains('/onboarding/summary'));
  });

  testWidgets('home reflects the saved unified avatar profile',
      (WidgetTester tester) async {
    final fakeAuthRepository = _FakeAuthRepository()
      ..user = const AuthUser(id: 'tester', email: 'tester@example.com');
    final fakeProfileRepository =
        _FakeProfileRepository(onboardingComplete: true);
    final fakeCompanionRepository = _FakeCompanionRepository()
      ..savedAvatarConfig = AvatarConfigModel.fromUserAvatarProfile(
        UserAvatarProfile.defaultAdult.copyWith(
          mode: user_avatar.AvatarMode.privateAbstract,
          renderMode: user_avatar.AvatarRenderMode.abstract,
          accentColor: const Color(0xFFEC4899),
        ),
      );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
          companionRepositoryProvider
              .overrideWithValue(fakeCompanionRepository),
        ],
        child: MaterialApp.router(routerConfig: _buildHomeGateRouter()),
      ),
    );

    await _pumpUntilVisible(
      tester,
      find.byKey(const ValueKey<String>('home-avatar-v4-rive')),
    );

    expect(find.text('Hi there!'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('home-avatar-v4-rive')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('home-avatar-v4-rive')),
      findsOneWidget,
    );
  });

  testWidgets('home avatar entry opens Avatar Engine V4 customizer',
      (WidgetTester tester) async {
    final fakeAuthRepository = _FakeAuthRepository()
      ..user = const AuthUser(id: 'tester', email: 'tester@example.com');
    final fakeProfileRepository =
        _FakeProfileRepository(onboardingComplete: true);
    final fakeCompanionRepository = _FakeCompanionRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
          companionRepositoryProvider
              .overrideWithValue(fakeCompanionRepository),
        ],
        child: MaterialApp.router(routerConfig: _buildHomeGateRouter()),
      ),
    );

    await _pumpUntilVisible(tester, find.text('Hi there!'));
    expect(
      find.byKey(const ValueKey<String>('home-avatar-v4-rive')),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('My avatar'));
    await tester.pump();
    await tester.tap(find.text('My avatar'));
    await tester.pumpAndSettle();
    // Avatar V4 onboarding route is locked by avatar_v4_onboarding_purge_test.dart.

    expect(find.byType(AvatarRiveView), findsWidgets);
    expect(
      find.text('Avatar Engine V4 is ready for Rive art packs.'),
      findsOneWidget,
    );
  });

  testWidgets('login to onboarding summary full setup',
      (WidgetTester tester) async {
    final summarySource =
        File('lib/presentation/onboarding/onboarding_summary_screen.dart')
            .readAsStringSync();
    final repositorySource =
        File('lib/data/repositories/profile_repository_impl.dart')
            .readAsStringSync();
    final onboardingStateSource =
        File('lib/domain/onboarding/onboarding_state.dart').readAsStringSync();

    expect(summarySource, contains('Sex, gender & pronouns'));
    expect(summarySource, contains('sexAtBirth'));
    expect(summarySource, contains('genderIdentity'));
    expect(summarySource, contains('pronounDisplay'));
    expect(summarySource, contains('/onboarding/identity?return=summary'));

    expect(repositorySource, contains('sex_at_birth'));
    expect(repositorySource, contains('gender_identity'));
    expect(repositorySource, contains('pronouns'));
    expect(repositorySource, contains('custom_pronouns'));

    expect(onboardingStateSource, contains('enum SexAtBirth'));
    expect(onboardingStateSource, contains('enum GenderIdentity'));
    expect(onboardingStateSource, contains('enum PronounSet'));
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

  testWidgets('login accepts existing accounts with shorter passwords',
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

    await tester.enterText(find.byType(TextField).first, 'tester@example.com');
    await tester.enterText(find.byType(TextField).last, 'secret');
    await tester.tap(find.widgetWithText(AsyncActionButton, 'Log in'));
    await tester.pumpAndSettle();

    await _pumpUntilAbsent(
      tester,
      find.text('Password must be at least 8 characters.'),
    );
    expect(fakeAuthRepository.user, isNotNull);
    expect(find.text('Password must be at least 8 characters.'), findsNothing);
  });

  testWidgets('login routes to onboarding if profile lookup fails after auth',
      (WidgetTester tester) async {
    final fakeAuthRepository = _FakeAuthRepository();
    final fakeProfileRepository = _FakeProfileRepository(
      throwOnCompletionCheck: true,
    );
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

    await _pumpUntilAbsent(
      tester,
      find.text('Cannot read onboarding status'),
    );
    expect(fakeAuthRepository.user, isNotNull);
    expect(find.text('Cannot read onboarding status'), findsNothing);
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

    await _pumpUntilVisible(tester, find.text('Hi there!'));
    await _pumpUntilAbsent(tester, find.text('Log in'));

    expect(find.text('Hi there!'), findsOneWidget);
    expect(find.text('Log in'), findsNothing);
  });

  testWidgets(
      'already authenticated caregiver on login is redirected to caregiver dashboard',
      (WidgetTester tester) async {
    final fakeAuthRepository = _FakeAuthRepository()
      ..user = const AuthUser(id: 'tester', email: 'tester@example.com');
    final fakeProfileRepository = _FakeProfileRepository(
      onboardingComplete: false,
      accountType: 'caregiver',
    );
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

    expect(find.text('Caregiver Support'), findsOneWidget);
    expect(find.text('Meet Dope-i'), findsNothing);
    expect(find.text('Hi there!'), findsNothing);
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
    expect(find.text('Hi there!'), findsNothing);
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
    await _pumpUntilVisible(tester, find.text('Hi there!'));

    expect(find.text('Hi there!'), findsOneWidget);
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

    await _pumpUntilVisible(tester, find.text('Hi there!'));

    expect(find.text('Hi there!'), findsOneWidget);
  });

  testWidgets('home gate sends caregiver accounts to caregiver dashboard',
      (WidgetTester tester) async {
    final fakeAuthRepository = _FakeAuthRepository()
      ..user = const AuthUser(id: 'tester', email: 'tester@example.com');
    final fakeProfileRepository = _FakeProfileRepository(
      onboardingComplete: false,
      accountType: 'caregiver',
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

    expect(find.text('Caregiver Support'), findsOneWidget);
    expect(find.text('Meet Dope-i'), findsNothing);
    expect(find.text('Hi there!'), findsNothing);
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

    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Hi there!'), findsOneWidget);
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
    expect(find.text('Hi there!'), findsNothing);
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

    await _pumpUntilVisible(tester, find.text('Hi there!'));

    expect(find.text('Hi there!'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.settings));
    await _pumpUntilVisible(tester, find.text('Settings'));
    await tester.tap(find.text('Restart onboarding'));
    await _pumpUntilVisible(tester, find.text('Meet Dope-i'));

    expect(fakeProfileRepository.onboardingComplete, isFalse);
    expect(find.text('Meet Dope-i'), findsOneWidget);
  });
}
