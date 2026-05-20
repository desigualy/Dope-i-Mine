import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dope_i_mine/data/repositories/auth_repository_impl.dart';
import 'package:dope_i_mine/data/repositories/caregiver_repository.dart';
import 'package:dope_i_mine/domain/auth/auth_user.dart';
import 'package:dope_i_mine/domain/body_double/body_double_session.dart';
import 'package:dope_i_mine/domain/caregiver/caregiver_models.dart';
import 'package:dope_i_mine/presentation/caregiver/caregiver_dashboard_screen.dart';
import 'package:dope_i_mine/presentation/caregiver/caregiver_controller.dart';
import 'package:dope_i_mine/providers.dart' hide caregiverRepositoryProvider;

void main() {
  test('controller can cancel pending caregiver invites', () async {
    final repository = _FakeCaregiverRepository(
      emailInvites: <CaregiverEmailInvite>[_pendingInvite],
    );
    final controller = CaregiverController(repository);
    addTearDown(controller.dispose);

    await _settleControllerRefresh();
    expect(controller.state.emailInvites, hasLength(1));

    await controller.cancelPendingInvite(_pendingInvite.id);

    expect(repository.cancelledInviteIds, contains(_pendingInvite.id));
    expect(controller.state.emailInvites, isEmpty);
  });

  test('controller can remove active caregiver relationships', () async {
    final repository = _FakeCaregiverRepository(
      relationships: <CaregiverRelationship>[_acceptedRelationship],
    );
    final controller = CaregiverController(repository);
    addTearDown(controller.dispose);

    await _settleControllerRefresh();
    expect(controller.state.relationships, hasLength(1));

    await controller.revokeRelationship(_acceptedRelationship.id);

    expect(
      repository.revokedRelationshipIds,
      contains(_acceptedRelationship.id),
    );
    expect(controller.state.relationships, isEmpty);
  });

  test(
    'controller returns invite send result so add screen only closes on success',
    () async {
      final repository = _FakeCaregiverRepository(sendInviteSucceeds: true);
      final controller = CaregiverController(repository);
      addTearDown(controller.dispose);

      await _settleControllerRefresh();
      final sent = await controller.sendRequest(
        'helper@example.com',
        CaregiverRole.caregiver,
        temporaryPassword: 'password123',
      );

      expect(sent, isTrue);
      expect(repository.createdInviteEmails, contains('helper@example.com'));
      expect(repository.createdInvitePasswords, contains('password123'));
      expect(controller.state.error, isNull);
    },
  );

  test(
    'controller accepts caregiver invite after setup email was already sent',
    () async {
      final repository = _FakeCaregiverRepository(
        acceptedInviteRelationship: _acceptedRelationship,
      );
      final controller = CaregiverController(repository);
      addTearDown(controller.dispose);

      await _settleControllerRefresh();
      final accepted = await controller.acceptEmailInvite(_pendingInvite.id);

      expect(accepted, isTrue);
      expect(repository.acceptedInviteIds, <String>[_pendingInvite.id]);
      expect(controller.state.relationships, contains(_acceptedRelationship));
      expect(controller.state.error, isNull);
    },
  );

  testWidgets(
    'caregiver dashboard opens linked user detail when caregiver relationship is loaded',
    (WidgetTester tester) async {
      const caregiverUser = AuthUser(
        id: 'caregiver-a',
        email: 'helper@example.com',
      );
      final authRepository = _FakeAuthRepository()..user = caregiverUser;
      final caregiverRepository = _FakeCaregiverRepository(
        relationships: <CaregiverRelationship>[_acceptedRelationship],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            authRepositoryProvider.overrideWithValue(authRepository),
            caregiverRepositoryProvider.overrideWithValue(caregiverRepository),
          ],
          child: const MaterialApp(
            home: CaregiverDashboardScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.text('User'), findsWidgets);
      expect(find.text('Assign Task'), findsOneWidget);
      expect(find.byTooltip('Account settings'), findsOneWidget);
      expect(find.text('Caregiver Support'), findsNothing);
      expect(find.text('No active support links'), findsNothing);
    },
  );
}

Future<void> _settleControllerRefresh() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

class _FakeAuthRepository implements AuthRepositoryImpl {
  AuthUser? user;

  @override
  Future<AuthUser?> signIn(
          {required String email, required String password}) async =>
      user;

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthUser?> signUp({
    required String email,
    required String password,
    String accountType = 'user',
  }) async =>
      user;

  @override
  AuthUser? getCurrentUser() => user;

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> updatePassword(String password) async {}

  @override
  Future<void> completeForcedPasswordChange(String password) async {}
}

final DateTime _now = DateTime.utc(2026, 5, 15, 12);

final CaregiverEmailInvite _pendingInvite = CaregiverEmailInvite(
  id: 'invite-a',
  inviterUserId: 'user-a',
  inviteeEmail: 'helper@example.com',
  role: CaregiverRole.caregiver,
  status: CaregiverEmailInviteStatus.pending,
  createdAt: _now,
  expiresAt: _now.add(const Duration(days: 30)),
);

final CaregiverRelationship _acceptedRelationship = CaregiverRelationship(
  id: 'rel-a',
  caregiverUserId: 'caregiver-a',
  supportedUserId: 'user-a',
  role: CaregiverRole.caregiver,
  status: CaregiverRelationshipStatus.accepted,
  relationshipLabel: 'Home support',
  createdAt: _now,
  acceptedAt: _now,
  caregiverName: 'Helper',
  supportedName: 'User',
);

class _FakeCaregiverRepository implements CaregiverRepository {
  _FakeCaregiverRepository({
    List<CaregiverRelationship> relationships = const <CaregiverRelationship>[],
    List<CaregiverEmailInvite> emailInvites = const <CaregiverEmailInvite>[],
    this.sendInviteSucceeds = true,
    this.acceptedInviteRelationship,
  })  : relationships = List<CaregiverRelationship>.of(relationships),
        emailInvites = List<CaregiverEmailInvite>.of(emailInvites);

  final List<CaregiverRelationship> relationships;
  final List<CaregiverEmailInvite> emailInvites;
  final bool sendInviteSucceeds;
  final CaregiverRelationship? acceptedInviteRelationship;
  final List<String> cancelledInviteIds = <String>[];
  final List<String> revokedRelationshipIds = <String>[];
  final List<String> createdInviteEmails = <String>[];
  final List<String> createdInvitePasswords = <String>[];
  final List<String> acceptedInviteIds = <String>[];

  @override
  Future<List<CaregiverRelationship>> loadRelationships() async =>
      List<CaregiverRelationship>.of(relationships);

  @override
  Future<List<CaregiverEmailInvite>> loadEmailInvites() async =>
      List<CaregiverEmailInvite>.of(emailInvites);

  @override
  Future<void> cancelEmailInvite(String inviteId) async {
    cancelledInviteIds.add(inviteId);
    emailInvites.removeWhere((invite) => invite.id == inviteId);
  }

  @override
  Future<CaregiverEmailInvite?> createEmailInvite({
    required String targetUserEmail,
    required CaregiverRole role,
    required String temporaryPassword,
  }) async {
    createdInviteEmails.add(targetUserEmail);
    createdInvitePasswords.add(temporaryPassword);
    if (!sendInviteSucceeds) return null;
    final invite = CaregiverEmailInvite(
      id: 'invite-${createdInviteEmails.length}',
      inviterUserId: 'user-a',
      inviteeEmail: targetUserEmail,
      role: role,
      status: CaregiverEmailInviteStatus.pending,
      createdAt: _now,
    );
    emailInvites.add(invite);
    return invite;
  }

  @override
  Future<void> revokeRelationship(String relationshipId) async {
    revokedRelationshipIds.add(relationshipId);
    relationships.removeWhere(
      (relationship) => relationship.id == relationshipId,
    );
  }

  @override
  Future<CaregiverRelationship?> acceptEmailInvite(String inviteId) async {
    acceptedInviteIds.add(inviteId);
    final relationship = acceptedInviteRelationship;
    if (relationship != null && !relationships.contains(relationship)) {
      relationships.add(relationship);
    }
    return relationship;
  }

  @override
  Future<CaregiverRelationship?> createRelationshipRequest({
    required String targetUserEmail,
    required CaregiverRole role,
    String? label,
  }) async =>
      null;

  @override
  Future<String> exportProgressReport(String userId) async => '';

  @override
  Future<void> assignRoutine({
    required String targetUserId,
    String? routineId,
    required String routineTitle,
    String schedule = 'Flexible',
  }) async {}

  @override
  Future<void> assignTask({
    required String targetUserId,
    required String taskTitle,
    String? taskDescription,
    List<String>? steps,
    DateTime? dueAt,
    String visibilityLevel = 'standard',
  }) async {}

  @override
  Future<void> inviteToBodyDouble({
    required String targetUserId,
    required String taskCategory,
    int durationMinutes = 25,
  }) async {}

  @override
  Future<List<CaregiverAlert>> loadAlerts(String relationshipId) async =>
      <CaregiverAlert>[];

  @override
  Future<List<CaregiverAssignedRoutine>> loadAssignedRoutines({
    String? targetUserId,
  }) async =>
      <CaregiverAssignedRoutine>[];

  @override
  Future<List<CaregiverAssignedTask>> loadAssignedTasks({
    String? targetUserId,
  }) async =>
      <CaregiverAssignedTask>[];

  @override
  Future<List<BodyDoubleSession>> loadBodyDoubleSummaries(
    String userId,
  ) async =>
      <BodyDoubleSession>[];

  @override
  Future<CaregiverPermissions?> loadPermissions(String relationshipId) async =>
      null;

  @override
  Future<void> respondToAssignedRoutine({
    required String assignedRoutineId,
    required CaregiverRoutineStatus status,
  }) async {}

  @override
  Future<void> respondToAssignedTask({
    required String assignedTaskId,
    required CaregiverTaskStatus status,
  }) async {}

  @override
  Future<void> respondToRelationshipRequest({
    required String relationshipId,
    required bool accept,
  }) async {}

  @override
  Future<void> sendNudge({
    required String relationshipId,
    required String targetUserId,
    required String message,
    CaregiverNudgeTone tone = CaregiverNudgeTone.gentle,
  }) async {}

  @override
  Future<void> setMinorRandomApproval({
    required String targetUserId,
    required bool approved,
  }) async {}

  @override
  Future<void> suggestSideQuest({
    required String targetUserId,
    required String title,
  }) async {}

  @override
  Future<void> updatePermissions(CaregiverPermissions permissions) async {}
}
