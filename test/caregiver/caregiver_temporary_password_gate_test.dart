import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:dope_i_mine/app/post_auth_route.dart';
import 'package:dope_i_mine/app/onboarding_gate_screen.dart';
import 'package:dope_i_mine/data/repositories/auth_repository_impl.dart';
import 'package:dope_i_mine/data/repositories/caregiver_repository.dart';
import 'package:dope_i_mine/data/repositories/profile_repository_impl.dart';
import 'package:dope_i_mine/domain/auth/auth_user.dart';
import 'package:dope_i_mine/domain/caregiver/caregiver_models.dart';
import 'package:dope_i_mine/presentation/auth/force_password_change_screen.dart';
import 'package:dope_i_mine/presentation/caregiver/link_caregiver_screen.dart';
import 'package:dope_i_mine/presentation/caregiver/caregiver_controller.dart';
import 'package:dope_i_mine/providers.dart' hide caregiverRepositoryProvider;

class _FakeAuthRepository extends Fake implements AuthRepositoryImpl {
  AuthUser? user;
  bool completeForcedPasswordChangeCalled = false;
  String? updatedPassword;

  @override
  AuthUser? getCurrentUser() => user;

  @override
  Future<void> completeForcedPasswordChange(String password) async {
    completeForcedPasswordChangeCalled = true;
    updatedPassword = password;
  }

  @override
  Future<void> updatePassword(String password) async {
    updatedPassword = password;
  }
}

class _FakeProfileRepository extends Fake implements ProfileRepositoryImpl {
  bool mustChange = false;
  bool onboardingComplete = false;
  String accountType = 'caregiver';

  @override
  Future<void> ensureProfileExists({
    required String userId,
    String? email,
    String accountType = 'user',
  }) async {}

  @override
  Future<String> getAccountType(String userId) async => accountType;

  @override
  Future<bool> isOnboardingComplete(String userId) async => onboardingComplete;

  @override
  Future<bool> mustChangePassword(String userId) async => mustChange;

  @override
  Future<void> clearMustChangePassword({required String userId}) async {
    mustChange = false;
  }

  @override
  Future<void> setOnboardingCompleted({
    required String userId,
    String? email,
    required bool completed,
  }) async {
    onboardingComplete = completed;
  }
}

class _FakeCaregiverRepository extends Fake implements CaregiverRepository {
  bool sendInviteSucceeds = true;
  String? lastTargetEmail;
  CaregiverRole? lastRole;
  String? lastTemporaryPassword;

  @override
  Future<List<CaregiverRelationship>> loadRelationships() async => [];

  @override
  Future<List<CaregiverEmailInvite>> loadEmailInvites() async => [];

  @override
  Future<List<CaregiverAssignedTask>> loadAssignedTasks(
          {String? targetUserId}) async =>
      [];

  @override
  Future<List<CaregiverAssignedRoutine>> loadAssignedRoutines(
          {String? targetUserId}) async =>
      [];

  @override
  Future<CaregiverEmailInvite?> createEmailInvite({
    required String targetUserEmail,
    required CaregiverRole role,
    required String temporaryPassword,
  }) async {
    lastTargetEmail = targetUserEmail;
    lastRole = role;
    lastTemporaryPassword = temporaryPassword;
    if (!sendInviteSucceeds) return null;
    return CaregiverEmailInvite(
      id: 'invite-1',
      inviterUserId: 'user-a',
      inviteeEmail: targetUserEmail,
      role: role,
      status: CaregiverEmailInviteStatus.pending,
      createdAt: DateTime.now(),
    );
  }
}

void main() {
  group('LinkCaregiverScreen Widget Tests', () {
    Future<void> _scrollToSendInvite(WidgetTester tester) async {
      // LinkCaregiverScreen uses a ListView which lazily builds children.
      // In widget tests the viewport is small, so the submit button may not be
      // built yet. Manually drag the list until the button is present.
      final sendButtonFinder =
          find.byKey(const Key('linkCaregiver_sendInvite'));
      final listFinder = find.byType(ListView);

      for (var i = 0; i < 10 && sendButtonFinder.evaluate().isEmpty; i++) {
        await tester.drag(listFinder, const Offset(0, -300));
        await tester.pump();
      }

      expect(sendButtonFinder, findsOneWidget,
          reason: 'Expected Send Invite button to be built after scrolling.');
    }

    testWidgets('LinkCaregiverScreen shows temporary password copy and labels',
        (WidgetTester tester) async {
      final caregiverRepository = _FakeCaregiverRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            caregiverRepositoryProvider.overrideWithValue(caregiverRepository),
          ],
          child: const MaterialApp(
            home: LinkCaregiverScreen(),
          ),
        ),
      );

      expect(find.textContaining('temporary password'), findsWidgets);
      expect(find.text('Create Temporary Password'), findsOneWidget);
      expect(find.text('Confirm Temporary Password'), findsOneWidget);
      expect(find.textContaining('permanent'), findsNothing);
    });

    testWidgets('Password mismatch prevents send', (WidgetTester tester) async {
      final caregiverRepository = _FakeCaregiverRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            caregiverRepositoryProvider.overrideWithValue(caregiverRepository),
          ],
          child: const MaterialApp(
            home: LinkCaregiverScreen(),
          ),
        ),
      );

      await tester.enterText(
          find.byType(TextField).at(0), 'helper@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'temporary123');
      await tester.enterText(find.byType(TextField).at(2), 'mismatch123');

      final sendButton = find.byKey(const Key('linkCaregiver_sendInvite'));
      await _scrollToSendInvite(tester);
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      expect(caregiverRepository.lastTargetEmail, isNull);
      expect(find.textContaining('Passwords do not match'), findsOneWidget);
    });

    testWidgets('Valid send passes temporaryPassword and success pops',
        (WidgetTester tester) async {
      final caregiverRepository = _FakeCaregiverRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            caregiverRepositoryProvider.overrideWithValue(caregiverRepository),
          ],
          child: const MaterialApp(
            home: LinkCaregiverScreen(),
          ),
        ),
      );

      await tester.enterText(
          find.byType(TextField).at(0), 'helper@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'temporary123');
      await tester.enterText(find.byType(TextField).at(2), 'temporary123');

      final sendButton = find.byKey(const Key('linkCaregiver_sendInvite'));
      await _scrollToSendInvite(tester);
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      expect(caregiverRepository.lastTargetEmail, 'helper@example.com');
      expect(caregiverRepository.lastTemporaryPassword, 'temporary123');
    });

    testWidgets('Send failure keeps screen open and shows state error',
        (WidgetTester tester) async {
      final caregiverRepository = _FakeCaregiverRepository()
        ..sendInviteSucceeds = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            caregiverRepositoryProvider.overrideWithValue(caregiverRepository),
          ],
          child: const MaterialApp(
            home: LinkCaregiverScreen(),
          ),
        ),
      );

      await tester.enterText(
          find.byType(TextField).at(0), 'helper@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'temporary123');
      await tester.enterText(find.byType(TextField).at(2), 'temporary123');

      final sendButton = find.byKey(const Key('linkCaregiver_sendInvite'));
      await _scrollToSendInvite(tester);
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      expect(find.byType(LinkCaregiverScreen), findsOneWidget);
      expect(find.textContaining('Could not create or send caregiver invite'),
          findsOneWidget);
    });
  });

  group('Caregiver Password Gate Routing and ForcePasswordChangeScreen Tests',
      () {
    testWidgets(
        'must_change_password true routes to /force-password-change in gate',
        (WidgetTester tester) async {
      final authRepository = _FakeAuthRepository()
        ..user = const AuthUser(id: 'user-a', email: 'helper@example.com');
      final profileRepository = _FakeProfileRepository()..mustChange = true;

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => OnboardingGateScreen(
              child: const Text('Dashboard'),
            ),
          ),
          GoRoute(
            path: '/force-password-change',
            builder: (_, __) => const Text('ForcePasswordChange'),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepository),
            profileRepositoryProvider.overrideWithValue(profileRepository),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('ForcePasswordChange'), findsOneWidget);
    });

    testWidgets('Forced password change calls completeForcedPasswordChange',
        (WidgetTester tester) async {
      final authRepository = _FakeAuthRepository()
        ..user = const AuthUser(id: 'user-a', email: 'helper@example.com');
      final profileRepository = _FakeProfileRepository()..mustChange = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepository),
            profileRepositoryProvider.overrideWithValue(profileRepository),
          ],
          child: const MaterialApp(
            home: ForcePasswordChangeScreen(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), 'newpassword123');
      await tester.enterText(find.byType(TextField).at(1), 'newpassword123');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(authRepository.completeForcedPasswordChangeCalled, isTrue);
      expect(authRepository.updatedPassword, 'newpassword123');
    });

    testWidgets(
        'resolvePostAuthRoute redirects unconfirmed caregiver to /caregiver/confirm',
        (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(
            _FakeProfileRepository()
              ..mustChange = false
              ..onboardingComplete = false
              ..accountType = 'caregiver',
          ),
        ],
      );
      addTearDown(container.dispose);

      final route = await resolvePostAuthRoute(
        _FakeWidgetRef(container),
        const AuthUser(id: 'user-a', email: 'helper@example.com'),
      );

      expect(route, '/caregiver/confirm');
    });

    testWidgets(
        'resolvePostAuthRoute redirects confirmed caregiver to /caregiver',
        (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(
            _FakeProfileRepository()
              ..mustChange = false
              ..onboardingComplete = true
              ..accountType = 'caregiver',
          ),
        ],
      );
      addTearDown(container.dispose);

      final route = await resolvePostAuthRoute(
        _FakeWidgetRef(container),
        const AuthUser(id: 'user-a', email: 'helper@example.com'),
      );

      expect(route, '/caregiver');
    });
  });
}

class _FakeWidgetRef extends Fake implements WidgetRef {
  _FakeWidgetRef(this.container);
  final ProviderContainer container;

  @override
  T read<T>(ProviderListenable<T> provider) => container.read(provider);
}
