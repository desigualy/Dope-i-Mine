import 'package:flutter_test/flutter_test.dart';

import 'package:dope_i_mine/data/repositories/caregiver_repository.dart';
import 'package:dope_i_mine/domain/body_double/body_double_session.dart';
import 'package:dope_i_mine/domain/caregiver/caregiver_models.dart';
import 'package:dope_i_mine/presentation/caregiver/caregiver_controller.dart';

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

    expect(repository.revokedRelationshipIds, contains(_acceptedRelationship.id));
    expect(controller.state.relationships, isEmpty);
  });

  test('controller returns invite send result so add screen only closes on success', () async {
    final repository = _FakeCaregiverRepository(sendInviteSucceeds: true);
    final controller = CaregiverController(repository);
    addTearDown(controller.dispose);

    await _settleControllerRefresh();
    final sent = await controller.sendRequest('helper@example.com', CaregiverRole.caregiver);

    expect(sent, isTrue);
    expect(repository.createdInviteEmails, contains('helper@example.com'));
    expect(controller.state.error, isNull);
  });
}

Future<void> _settleControllerRefresh() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
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
  })  : relationships = List<CaregiverRelationship>.of(relationships),
        emailInvites = List<CaregiverEmailInvite>.of(emailInvites);

  final List<CaregiverRelationship> relationships;
  final List<CaregiverEmailInvite> emailInvites;
  final bool sendInviteSucceeds;
  final List<String> cancelledInviteIds = <String>[];
  final List<String> revokedRelationshipIds = <String>[];
  final List<String> createdInviteEmails = <String>[];

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
  }) async {
    createdInviteEmails.add(targetUserEmail);
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
    relationships.removeWhere((relationship) => relationship.id == relationshipId);
  }

  @override
  Future<CaregiverRelationship?> acceptEmailInvite(String inviteId) async => null;

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
    required String routineId,
  }) async {}

  @override
  Future<void> assignTask({
    required String targetUserId,
    required String taskTitle,
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
  Future<List<CaregiverAssignedRoutine>> loadAssignedRoutines({String? targetUserId}) async =>
      <CaregiverAssignedRoutine>[];

  @override
  Future<List<CaregiverAssignedTask>> loadAssignedTasks({String? targetUserId}) async =>
      <CaregiverAssignedTask>[];

  @override
  Future<List<BodyDoubleSession>> loadBodyDoubleSummaries(String userId) async =>
      <BodyDoubleSession>[];

  @override
  Future<CaregiverPermissions?> loadPermissions(String relationshipId) async => null;

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
  Future<bool> sendPasswordSetupEmailForAcceptedInvite(String inviteId) async => false;

  @override
  Future<void> sendNudge({
    required String relationshipId,
    required String targetUserId,
    required String message,
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
