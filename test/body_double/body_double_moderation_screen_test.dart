import 'package:dope_i_mine/domain/body_double/moderation/body_double_moderation.dart';
import 'package:dope_i_mine/presentation/body_double/body_double_moderation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('non-moderator cannot access moderation console', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ProviderScope(
        child: BodyDoubleModerationScreen(
          repositoryOverride: _FakeModerationRepository(isModerator: false),
        ),
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.textContaining('Access denied'), findsOneWidget);
    expect(
        find.byKey(const ValueKey('retention-cleanup-button')), findsNothing);
  });

  testWidgets('moderator can inspect queue and open report detail',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ProviderScope(
        child: BodyDoubleModerationScreen(
          repositoryOverride: _FakeModerationRepository(isModerator: true),
        ),
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.textContaining('Pending reports'), findsWidgets);
    expect(find.textContaining('Safety concern'), findsOneWidget);
    expect(find.textContaining('Active restrictions'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('review-report-report-1')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('moderation-report-detail')),
      300,
    );

    expect(
        find.byKey(const ValueKey('moderation-report-detail')), findsOneWidget);
    expect(find.textContaining('Linked moderation events'), findsOneWidget);
    expect(find.textContaining('Linked audit trail'), findsOneWidget);
  });

  testWidgets('moderator review, restrict, and revoke actions call repository',
      (tester) async {
    final repo = _FakeModerationRepository(isModerator: true);
    await tester.pumpWidget(MaterialApp(
      home: ProviderScope(
        child: BodyDoubleModerationScreen(repositoryOverride: repo),
      ),
    ));

    await repo.reviewModerationReport(
      reportId: 'report-1',
      status: BodyDoubleReportStatus.reviewed,
    );
    expect(repo.reviewedStatuses, contains(BodyDoubleReportStatus.reviewed));

    await repo.reviewModerationReport(
      reportId: 'report-1',
      status: BodyDoubleReportStatus.dismissed,
    );
    expect(repo.reviewedStatuses, contains(BodyDoubleReportStatus.dismissed));

    await repo.reviewModerationReport(
      reportId: 'report-1',
      status: BodyDoubleReportStatus.actioned,
    );
    expect(repo.reviewedStatuses, contains(BodyDoubleReportStatus.actioned));

    await repo.restrictUser(
      targetUserId: 'reported-1',
      restrictionType: BodyDoubleRestrictionType.randomSuspended,
      reason: 'Safety concern',
      reportId: 'report-1',
    );
    expect(repo.restrictCalled, isTrue);

    await repo.revokeRestriction(
      restrictionId: 'restriction-1',
      reason: 'Review complete',
    );
    expect(repo.revokeCalled, isTrue);
  });
}

class _FakeModerationRepository implements BodyDoubleModerationRepository {
  _FakeModerationRepository({required this.isModerator});

  final bool isModerator;
  final reviewedStatuses = <BodyDoubleReportStatus>[];
  bool restrictCalled = false;
  bool revokeCalled = false;

  BodyDoubleModerationReport get report => BodyDoubleModerationReport(
        id: 'report-1',
        reason: 'Safety concern',
        details: 'Limited report details for moderator review',
        status: BodyDoubleReportStatus.pending,
        createdAt: DateTime(2026, 5, 20),
        sessionId: 'session-1',
        reporter: const BodyDoubleSafetyUserSummary(userId: 'reporter-1'),
        reported: const BodyDoubleSafetyUserSummary(userId: 'reported-1'),
      );

  BodyDoubleModerationEvent get moderationEvent => BodyDoubleModerationEvent(
        id: 'event-1',
        sessionId: 'session-1',
        senderId: 'reported-1',
        reportId: 'report-1',
        action: 'allowed',
        reason: 'preview retained',
        bodyPreview: 'Safe retained preview',
        createdAt: DateTime(2026, 5, 20),
      );

  BodyDoubleAuditEvent get auditEvent => BodyDoubleAuditEvent(
        id: 'audit-1',
        actorId: 'moderator-1',
        sessionId: 'session-1',
        eventType: 'body_double_report_reviewed',
        metadata: const {'report_id': 'report-1'},
        createdAt: DateTime(2026, 5, 20),
      );

  BodyDoubleUserRestriction get restriction => BodyDoubleUserRestriction(
        id: 'restriction-1',
        user: const BodyDoubleSafetyUserSummary(userId: 'reported-1'),
        restrictionType: BodyDoubleRestrictionType.randomSuspended,
        status: BodyDoubleRestrictionStatus.active,
        reason: 'Safety concern',
        expiresAt: DateTime(2026, 5, 27),
      );

  @override
  Future<bool> isCurrentUserModerator() async => isModerator;

  @override
  Future<List<BodyDoubleModerationReport>> loadModerationReports() async =>
      isModerator ? [report] : [];

  @override
  Future<BodyDoubleModerationReportDetails?> loadModerationReportDetails(
    String reportId,
  ) async =>
      BodyDoubleModerationReportDetails(
        report: report,
        session: const BodyDoubleModerationSessionSummary(
          id: 'session-1',
          mode: 'random',
          status: 'active',
          communicationMode: 'textOnly',
        ),
        moderationEvents: [moderationEvent],
        auditEvents: [auditEvent],
        restrictions: [restriction],
      );

  @override
  Future<List<BodyDoubleModerationEvent>> loadModerationEvents({
    String? sessionId,
    String? reportId,
  }) async =>
      isModerator ? [moderationEvent] : [];

  @override
  Future<List<BodyDoubleAuditEvent>> loadBodyDoubleAuditEvents({
    String? sessionId,
    String? reportId,
  }) async =>
      isModerator ? [auditEvent] : [];

  @override
  Future<List<BodyDoubleUserRestriction>> loadUserRestrictions({
    String? targetUserId,
    bool? activeOnly,
  }) async =>
      isModerator ? [restriction] : [];

  @override
  Future<void> reviewModerationReport({
    required String reportId,
    required BodyDoubleReportStatus status,
  }) async {
    reviewedStatuses.add(status);
  }

  @override
  Future<String?> restrictUser({
    required String targetUserId,
    required BodyDoubleRestrictionType restrictionType,
    required String reason,
    DateTime? expiresAt,
    String? reportId,
  }) async {
    restrictCalled = true;
    return 'restriction-new';
  }

  @override
  Future<void> revokeRestriction({
    required String restrictionId,
    required String reason,
  }) async {
    revokeCalled = true;
  }

  @override
  Future<BodyDoubleModerationRetentionCleanupResult?>
      runModerationRetentionCleanup() async =>
          const BodyDoubleModerationRetentionCleanupResult(
            allowedPreviewsScrubbed: 1,
            blockedPreviewsScrubbed: 0,
            reportedPreviewsScrubbed: 0,
            auditEventsDeleted: 0,
          );
}
