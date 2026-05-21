import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/body_double/moderation/body_double_moderation.dart';
import '../../domain/body_double/body_double_session.dart';
import '../local/local_body_double_store.dart';

class BodyDoubleRepositoryImpl implements BodyDoubleModerationRepository {
  BodyDoubleRepositoryImpl({
    required LocalBodyDoubleStore localStore,
    this.client,
    this.userId,
  }) : _localStore = localStore;

  final LocalBodyDoubleStore _localStore;
  final SupabaseClient? client;
  final String? userId;

  Future<void> saveActiveSession(BodyDoubleSession session) async {
    await _localStore.saveActiveSession(session);
    await _syncSession(session);
  }

  Future<BodyDoubleSession?> loadActiveSession() {
    return _localStore.loadActiveSession();
  }

  Future<BodyDoubleSession?> loadLastSummary() {
    return _localStore.loadLastSummary();
  }

  Future<void> saveSummary(BodyDoubleSession session) async {
    await _localStore.saveSummary(session);
    await _syncSession(session);
  }

  Future<void> saveFriendInvite(BodyDoubleInvite invite) async {
    final hasRemoteUser =
        client != null && userId != null && userId!.isNotEmpty;
    if (hasRemoteUser) {
      await _syncInvite(invite);
    }
    await _localStore.saveFriendInvite(invite);
  }

  Future<List<BodyDoubleInvite>> loadFriendInvites() {
    return _localStore.loadFriendInvites();
  }

  Future<void> saveParticipant(BodyDoubleParticipant participant) async {
    await _localStore.saveParticipant(participant);
    await _syncParticipant(participant);
  }

  Future<List<BodyDoubleParticipant>> loadParticipants() {
    return _localStore.loadParticipants();
  }

  Future<void> saveSignal(BodyDoubleSignal signal) async {
    await _localStore.saveSignal(signal);
  }

  Future<List<BodyDoubleSignal>> loadSignals() {
    return _localStore.loadSignals();
  }

  Future<RandomBodyDoubleEligibility?> loadRandomEligibility() async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) return null;
    try {
      final rows = await client.rpc<List<dynamic>>(
        'get_random_body_double_eligibility',
        params: <String, dynamic>{'p_user_id': userId},
      );
      if (rows.isEmpty) return null;
      return RandomBodyDoubleEligibility.fromJson(
        Map<String, dynamic>.from(rows.first as Map),
      );
    } catch (error) {
      debugPrint('Body double random eligibility load skipped: $error');
      return null;
    }
  }

  Future<RandomBodyDoubleSafetySettings?> loadRandomSafetySettings() async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) return null;
    try {
      final row = await client
          .from('body_double_random_safety_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (row == null) {
        return RandomBodyDoubleSafetySettings(userId: userId);
      }
      return RandomBodyDoubleSafetySettings.fromJson(row);
    } catch (error) {
      debugPrint('Body double random settings load skipped: $error');
      return null;
    }
  }

  Future<void> saveAdultRandomSafetySettings({
    required bool randomMatchingEnabled,
    required bool presetSignalsAllowed,
    required bool quietModeAllowed,
    bool textAllowed = false,
    bool voiceAllowed = false,
  }) async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) return;
    try {
      await client.rpc<void>(
        'set_adult_random_body_double_settings',
        params: <String, dynamic>{
          'p_random_matching_enabled': randomMatchingEnabled,
          'p_preset_signals_allowed': presetSignalsAllowed,
          'p_quiet_mode_allowed': quietModeAllowed,
          'p_text_allowed': textAllowed,
          'p_voice_allowed': voiceAllowed,
        },
      );
    } catch (error) {
      debugPrint('Body double random settings save skipped: $error');
    }
  }

  Future<List<Map<String, dynamic>>> loadCaregiverMinorLinks() async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) {
      return const <Map<String, dynamic>>[];
    }
    try {
      final rows = await client
          .from('caregiver_links')
          .select(
              'primary_user_id, permission_level, status, users_profile!caregiver_links_primary_user_id_fkey(age_band, display_name)')
          .eq('caregiver_user_id', userId)
          .eq('status', 'active');
      return (rows as List<dynamic>)
          .map((row) => Map<String, dynamic>.from(row as Map))
          .where((row) {
        final profile = row['users_profile'];
        if (profile is! Map) return true;
        final ageBand = profile['age_band'] as String? ?? 'adult';
        return ageBand != 'adult';
      }).toList();
    } catch (error) {
      debugPrint('Body double caregiver minor links load skipped: $error');
      return const <Map<String, dynamic>>[];
    }
  }

  Future<void> setGuardianRandomApproval({
    required String targetUserId,
    required bool approved,
  }) async {
    final client = this.client;
    final approverId = userId;
    if (client == null || approverId == null || approverId.isEmpty) return;
    try {
      await client.rpc<void>(
        'set_minor_random_body_double_guardian_approval',
        params: <String, dynamic>{
          'p_target_user_id': targetUserId,
          'p_approved': approved,
        },
      );
    } catch (error) {
      debugPrint('Body double guardian random approval skipped: $error');
    }
  }

  Future<String?> enterRandomQueue({
    required BodyDoubleSessionType sessionType,
    required String taskCategory,
    required int sessionLengthMinutes,
    required BodyDoubleCommunicationMode communicationMode,
    required BodyDoublePrivacyLevel privacyLevel,
    String language = 'en',
    String? timezone,
  }) async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) return null;
    try {
      final queueId = await client.rpc<String>(
        'enter_random_body_double_queue',
        params: <String, dynamic>{
          'p_session_type': sessionType.name,
          'p_task_category': taskCategory,
          'p_session_length_minutes': sessionLengthMinutes,
          'p_communication_mode': communicationMode.name,
          'p_privacy_level': privacyLevel.name,
          'p_language': language,
          'p_timezone': timezone,
        },
      );
      return queueId;
    } catch (error) {
      debugPrint('Body double random queue entry skipped: $error');
      return null;
    }
  }

  Future<String?> enterGroupBodyDoubleQueue({
    required BodyDoubleSessionType sessionType,
    required String taskCategory,
    required int sessionLengthMinutes,
    BodyDoubleCommunicationMode communicationMode =
        BodyDoubleCommunicationMode.presetSignals,
    BodyDoublePrivacyLevel privacyLevel = BodyDoublePrivacyLevel.titleOnly,
    int maxGroupSize = BodyDoubleGroupPolicy.maximumParticipants,
    String language = 'en',
    String? timezone,
  }) async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) return null;
    try {
      return await client.rpc<String>(
        'enter_group_body_double_queue',
        params: <String, dynamic>{
          'p_session_type': sessionType.name,
          'p_task_category': taskCategory,
          'p_session_length_minutes': sessionLengthMinutes,
          'p_communication_mode': communicationMode.name,
          'p_privacy_level': privacyLevel.name,
          'p_max_group_size': maxGroupSize,
          'p_language': language,
          'p_timezone': timezone,
        },
      );
    } catch (error) {
      debugPrint('Body double group queue entry skipped: $error');
      return null;
    }
  }

  Future<String?> findGroupBodyDoubleMatch(String queueId) async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) return null;
    try {
      return await client.rpc<String?>(
        'find_group_body_double_match',
        params: <String, dynamic>{'p_queue_id': queueId},
      );
    } catch (error) {
      debugPrint('Body double group match skipped: $error');
      return null;
    }
  }

  Future<void> leaveGroupBodyDoubleSession(String sessionId) async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) return;
    try {
      await client.rpc<void>(
        'leave_group_body_double_session',
        params: <String, dynamic>{'p_session_id': sessionId},
      );
    } catch (error) {
      debugPrint('Body double group leave skipped: $error');
    }
  }

  Future<String?> createKnownGroupBodyDoubleInvite({
    required String sessionId,
    required String receiverId,
  }) async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) return null;
    try {
      return await client.rpc<String>(
        'create_known_group_body_double_invite',
        params: <String, dynamic>{
          'p_session_id': sessionId,
          'p_receiver_id': receiverId,
        },
      );
    } catch (error) {
      debugPrint('Known group invite skipped: $error');
      return null;
    }
  }

  Future<void> cancelRandomQueue(String queueId) async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) return;
    try {
      await client.rpc<void>(
        'cancel_random_body_double_queue',
        params: <String, dynamic>{'p_queue_id': queueId},
      );
    } catch (error) {
      debugPrint('Body double random queue cancel skipped: $error');
    }
  }

  Future<String?> sendRandomTextMessage({
    required String sessionId,
    required String text,
  }) async {
    final safety = RandomBodyDoubleTextSafety.check(text);
    if (!safety.isAllowed) return safety.userMessage;
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) {
      return 'Message was not sent. Random text requires a signed-in safe session.';
    }
    try {
      await client.rpc<void>(
        'send_random_body_double_text_message',
        params: <String, dynamic>{
          'p_session_id': sessionId,
          'p_body': safety.sanitizedText,
        },
      );
      return null;
    } catch (error) {
      debugPrint('Body double random text send skipped: $error');
      return 'Message was not sent. Random text is filtered and adult-only.';
    }
  }

  Future<String?> reportRandomSession({
    required String sessionId,
    required String reportedUserId,
    required String reason,
    required String details,
  }) async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) return null;
    try {
      return await client.rpc<String>(
        'report_random_body_double_session',
        params: <String, dynamic>{
          'p_session_id': sessionId,
          'p_reported_user_id': reportedUserId,
          'p_reason': reason,
          'p_details': details,
        },
      );
    } catch (error) {
      debugPrint('Body double random report skipped: $error');
      return null;
    }
  }

  @override
  Future<bool> isCurrentUserModerator() async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) return false;
    try {
      return await client.rpc<bool>('is_body_double_moderator');
    } catch (error) {
      debugPrint('Body double moderator check skipped: $error');
      return false;
    }
  }

  @override
  Future<List<BodyDoubleModerationReport>> loadModerationReports() async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) {
      return const <BodyDoubleModerationReport>[];
    }
    try {
      final rows = await client
          .from('user_reports')
          .select(
              'id, reporter_id, reported_id, session_id, reason, details, status, created_at, '
              'reported_profile:users_profile!user_reports_reported_id_fkey(display_name, age_band, reliability_score), '
              'reporter_profile:users_profile!user_reports_reporter_id_fkey(display_name, age_band, reliability_score)')
          .order('status', ascending: false)
          .order('created_at', ascending: false)
          .limit(50);
      return (rows as List<dynamic>)
          .map((row) => BodyDoubleModerationReport.fromJson(
                Map<String, dynamic>.from(row as Map),
              ))
          .toList();
    } catch (error) {
      debugPrint('Body double moderation reports load skipped: $error');
      return const <BodyDoubleModerationReport>[];
    }
  }

  @override
  Future<BodyDoubleModerationReportDetails?> loadModerationReportDetails(
    String reportId,
  ) async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) return null;
    try {
      final row = await client
          .from('user_reports')
          .select(
              'id, reporter_id, reported_id, session_id, reason, details, status, created_at, '
              'reported_profile:users_profile!user_reports_reported_id_fkey(display_name, age_band, reliability_score), '
              'reporter_profile:users_profile!user_reports_reporter_id_fkey(display_name, age_band, reliability_score)')
          .eq('id', reportId)
          .maybeSingle();
      if (row == null) return null;
      final report = BodyDoubleModerationReport.fromJson(row);
      BodyDoubleModerationSessionSummary? session;
      if (report.sessionId != null) {
        final sessionRow = await client
            .from('body_double_sessions')
            .select(
                'id, mode, status, session_type, communication_mode, privacy_level, started_at, ended_at')
            .eq('id', report.sessionId!)
            .maybeSingle();
        if (sessionRow != null) {
          session = BodyDoubleModerationSessionSummary.fromJson(sessionRow);
        }
      }
      final restrictions = await loadUserRestrictions(
        targetUserId: report.reported?.userId,
      );
      return BodyDoubleModerationReportDetails(
        report: report,
        session: session,
        moderationEvents: await loadModerationEvents(
          sessionId: report.sessionId,
          reportId: report.id,
        ),
        auditEvents: await loadBodyDoubleAuditEvents(
          sessionId: report.sessionId,
          reportId: report.id,
        ),
        restrictions: restrictions,
      );
    } catch (error) {
      debugPrint('Body double moderation report detail load skipped: $error');
      return null;
    }
  }

  @override
  Future<void> reviewModerationReport({
    required String reportId,
    required BodyDoubleReportStatus status,
  }) async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) return;
    try {
      await client.rpc<void>(
        'review_body_double_report',
        params: <String, dynamic>{
          'p_report_id': reportId,
          'p_status': status.value,
        },
      );
    } catch (error) {
      debugPrint('Body double moderation review skipped: $error');
    }
  }

  Future<List<BodyDoubleAuditEvent>> loadModerationAuditEvents() {
    return loadBodyDoubleAuditEvents();
  }

  @override
  Future<List<BodyDoubleAuditEvent>> loadBodyDoubleAuditEvents({
    String? sessionId,
    String? reportId,
  }) async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) {
      return const <BodyDoubleAuditEvent>[];
    }
    try {
      var query = client.from('body_double_audit_events').select(
          'id, actor_id, session_id, queue_id, event_type, metadata, created_at');
      if (sessionId != null && sessionId.isNotEmpty) {
        query = query.eq('session_id', sessionId);
      }
      final rows = await query.order('created_at', ascending: false).limit(100);
      final events = (rows as List<dynamic>)
          .map((row) => BodyDoubleAuditEvent.fromJson(
                Map<String, dynamic>.from(row as Map),
              ))
          .toList();
      if (reportId == null || reportId.isEmpty) return events;
      return events
          .where((event) => event.metadata['report_id']?.toString() == reportId)
          .toList();
    } catch (error) {
      debugPrint('Body double moderation audit load skipped: $error');
      return const <BodyDoubleAuditEvent>[];
    }
  }

  Future<List<BodyDoubleModerationEvent>> loadMessageModerationEvents() {
    return loadModerationEvents();
  }

  @override
  Future<List<BodyDoubleModerationEvent>> loadModerationEvents({
    String? sessionId,
    String? reportId,
  }) async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) {
      return const <BodyDoubleModerationEvent>[];
    }
    try {
      var query = client.from('body_double_message_moderation_events').select(
          'id, session_id, sender_id, message_id, report_id, action, reason, body_preview, created_at');
      if (sessionId != null && sessionId.isNotEmpty) {
        query = query.eq('session_id', sessionId);
      }
      if (reportId != null && reportId.isNotEmpty) {
        query = query.eq('report_id', reportId);
      }
      final rows = await query.order('created_at', ascending: false).limit(100);
      return (rows as List<dynamic>)
          .map((row) => BodyDoubleModerationEvent.fromJson(
                Map<String, dynamic>.from(row as Map),
              ))
          .toList();
    } catch (error) {
      debugPrint('Body double message moderation load skipped: $error');
      return const <BodyDoubleModerationEvent>[];
    }
  }

  @override
  Future<List<BodyDoubleUserRestriction>> loadUserRestrictions({
    String? targetUserId,
    bool? activeOnly,
  }) async {
    final client = this.client;
    final currentUserId = userId;
    if (client == null || currentUserId == null || currentUserId.isEmpty) {
      return const <BodyDoubleUserRestriction>[];
    }
    try {
      var query = client.from('body_double_user_restrictions').select(
          'id, user_id, restricted_by, restriction_type, reason, status, starts_at, expires_at, created_at, '
          'user_profile:users_profile(display_name, age_band, reliability_score)');
      if (targetUserId != null && targetUserId.isNotEmpty) {
        query = query.eq('user_id', targetUserId);
      }
      if (activeOnly == true) {
        query = query.eq('status', 'active');
      }
      final rows = await query.order('created_at', ascending: false).limit(100);
      return (rows as List<dynamic>)
          .map((row) => BodyDoubleUserRestriction.fromJson(
                Map<String, dynamic>.from(row as Map),
              ))
          .toList();
    } catch (error) {
      debugPrint('Body double restrictions load skipped: $error');
      return const <BodyDoubleUserRestriction>[];
    }
  }

  @override
  Future<String?> restrictUser({
    required String targetUserId,
    required BodyDoubleRestrictionType restrictionType,
    required String reason,
    DateTime? expiresAt,
    String? reportId,
  }) async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) return null;
    try {
      return await client.rpc<String>(
        'restrict_body_double_user',
        params: <String, dynamic>{
          'p_user_id': targetUserId,
          'p_restriction_type': restrictionType.value,
          'p_reason': reason,
          'p_expires_at': expiresAt?.toIso8601String(),
          'p_report_id': reportId,
        },
      );
    } catch (error) {
      debugPrint('Body double user restriction skipped: $error');
      return null;
    }
  }

  @override
  Future<void> revokeRestriction({
    required String restrictionId,
    required String reason,
  }) async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) return;
    try {
      await client.rpc<void>(
        'revoke_body_double_user_restriction',
        params: <String, dynamic>{
          'p_restriction_id': restrictionId,
          'p_reason': reason,
        },
      );
    } catch (error) {
      debugPrint('Body double restriction revoke skipped: $error');
    }
  }

  @override
  Future<BodyDoubleModerationRetentionCleanupResult?>
      runModerationRetentionCleanup() async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) return null;
    try {
      final rows = await client.rpc<List<dynamic>>(
        'cleanup_body_double_moderation_retention',
      );
      if (rows.isEmpty) {
        return const BodyDoubleModerationRetentionCleanupResult(
          allowedPreviewsScrubbed: 0,
          blockedPreviewsScrubbed: 0,
          reportedPreviewsScrubbed: 0,
          auditEventsDeleted: 0,
        );
      }
      return BodyDoubleModerationRetentionCleanupResult.fromJson(
        Map<String, dynamic>.from(rows.first as Map),
      );
    } catch (error) {
      debugPrint('Body double moderation retention cleanup skipped: $error');
      return null;
    }
  }

  Future<Map<String, int>?> cleanupRandomLifecycle() async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) return null;
    try {
      final rows = await client.rpc<List<dynamic>>(
        'cleanup_body_double_random_lifecycle',
      );
      if (rows.isEmpty) {
        return <String, int>{'expiredQueues': 0, 'closedSessions': 0};
      }
      final row = Map<String, dynamic>.from(rows.first as Map);
      return <String, int>{
        'expiredQueues': row['expired_queues'] as int? ?? 0,
        'stalePresence': row['stale_presence'] as int? ?? 0,
        'closedSessions': row['closed_sessions'] as int? ?? 0,
      };
    } catch (error) {
      debugPrint('Body double random cleanup skipped: $error');
      return null;
    }
  }

  Future<List<BodyDoubleInvite>> loadRemotePendingInvites() async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) {
      return const <BodyDoubleInvite>[];
    }
    try {
      final rows = await client
          .from('body_double_invites')
          .select()
          .or('receiver_id.eq.$userId,sender_id.eq.$userId')
          .eq('status', 'pending');
      return (rows as List<dynamic>)
          .map((row) =>
              BodyDoubleInvite.fromJson(Map<String, dynamic>.from(row as Map)))
          .toList();
    } catch (e) {
      debugPrint('Body double load remote invites skipped: $e');
      return const <BodyDoubleInvite>[];
    }
  }

  Future<BodyDoubleSession?> loadRemoteSession(String sessionId) async {
    final client = this.client;
    if (client == null) return null;
    try {
      final row = await client
          .from('body_double_sessions')
          .select()
          .or('client_session_id.eq.$sessionId,id.eq.$sessionId')
          .maybeSingle();
      if (row == null) return null;
      return BodyDoubleSession.fromJson(row);
    } catch (e) {
      debugPrint('Body double load remote session skipped: $e');
      return null;
    }
  }

  Future<BodyDoubleSession?> loadMatchedRandomSession(String queueId) async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) return null;
    try {
      final row = await client
          .from('body_double_queue')
          .select('matched_session_id')
          .eq('id', queueId)
          .eq('user_id', userId)
          .maybeSingle();
      final sessionId = row?['matched_session_id'] as String?;
      if (sessionId == null || sessionId.isEmpty) return null;
      return loadRemoteSession(sessionId);
    } catch (error) {
      debugPrint('Body double matched random session load skipped: $error');
      return null;
    }
  }

  Future<void> _syncSession(BodyDoubleSession session) async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) return;
    try {
      await client.from('body_double_sessions').upsert(
            _toRemoteRow(session, userId),
            onConflict: 'user_id,client_session_id',
          );
    } catch (error) {
      debugPrint('Body double remote sync skipped: $error');
    }
  }

  Future<void> _syncInvite(BodyDoubleInvite invite) async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) return;
    await client.from('body_double_invites').upsert(
      <String, dynamic>{
        'client_invite_id': invite.id,
        'session_client_id': invite.sessionId,
        'sender_id': invite.senderId,
        'receiver_id': invite.receiverId,
        'status': invite.status.name,
        'is_spur_a_on': invite.isSpurAOn,
        'expires_at': invite.expiresAt.toIso8601String(),
        'created_at': invite.createdAt.toIso8601String(),
        'responded_at': invite.respondedAt?.toIso8601String(),
      },
      onConflict: 'client_invite_id',
    );
  }

  Future<void> _syncParticipant(BodyDoubleParticipant participant) async {
    final client = this.client;
    final userId = this.userId;
    if (client == null || userId == null || userId.isEmpty) return;
    if (!_isUuid(participant.sessionId)) return;
    try {
      await client.from('body_double_participants').upsert(
        <String, dynamic>{
          'session_id': participant.sessionId,
          'user_id': participant.userId,
          'role': participant.role,
          'status': participant.status.name,
          'joined_at': participant.joinedAt?.toIso8601String(),
          'left_at': participant.leftAt?.toIso8601String(),
          'age_band_snapshot': participant.ageBandSnapshot?.name,
          'display_name_snapshot': participant.displayNameSnapshot,
          'anonymous_label': participant.anonymousLabel,
        },
        onConflict: 'session_id,user_id',
      );
    } catch (error) {
      debugPrint('Body double participant remote sync skipped: $error');
    }
  }

  Map<String, dynamic> _toRemoteRow(BodyDoubleSession session, String userId) {
    return <String, dynamic>{
      'client_session_id': session.id,
      'user_id': userId,
      'mode': session.mode.name,
      'status': session.status.name,
      'task_id': _uuidOrNull(session.taskId),
      'task_title': session.taskTitle,
      'session_type': session.sessionType.name,
      'session_length_minutes': session.sessionLengthMinutes,
      'communication_mode': session.communicationMode.name,
      'privacy_level': session.privacyLevel.name,
      'created_by': session.createdBy ?? userId,
      'max_participants': session.maxParticipants,
      'current_participant_count': session.currentParticipantCount,
      'check_in_interval_minutes': session.checkInIntervalMinutes,
      'steps_completed': session.stepsCompleted,
      'overwhelm_events': session.overwhelmEvents,
      'summary': session.summary,
      'started_at': session.startedAt.toIso8601String(),
      'ended_at': session.endedAt?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  String? _uuidOrNull(String? value) {
    if (value == null) return null;
    final uuidPattern = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidPattern.hasMatch(value) ? value : null;
  }

  bool _isUuid(String value) {
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(value);
  }

  Future<void> updateReliabilityScore({
    required String userId,
    required bool completed,
  }) async {
    final client = this.client;
    if (client == null) return;
    try {
      final change = completed ? 5 : -10;
      await client.rpc('update_user_reliability_score', params: {
        'p_user_id': userId,
        'p_change': change,
        'p_completed': completed,
      });
    } catch (_) {
      // Reliability score update is best-effort
    }
  }

  Future<String> getDopeiSummaryNote({
    required int stepsCompleted,
    required int totalMinutes,
  }) async {
    if (stepsCompleted == 0) {
      return 'Sometimes just showing up is the hardest part. You stayed present, and that matters. Dope-i is proud of you.';
    }
    if (stepsCompleted > 5) {
      return "Wow! You were on fire today. $stepsCompleted steps completed! You've made so much progress. Time to celebrate!";
    }
    return "Great focus! You knocked out $stepsCompleted steps. You're closer to your goal now. Rest well!";
  }
}
