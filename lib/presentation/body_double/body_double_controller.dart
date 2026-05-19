import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/local/local_body_double_store.dart';
import '../../data/local/local_reward_store.dart';
import '../../data/repositories/body_double_repository_impl.dart';
import '../../domain/body_double/body_double_session.dart';
import '../../domain/tasks/task_step_model.dart';
import '../tasks/task_controller.dart';
import '../../providers.dart';

class BodyDoubleState {
  const BodyDoubleState({
    this.activeSession,
    this.lastSummary,
    this.currentStepText,
    this.nextCheckInAt,
    this.remainingSeconds,
    this.checkInDue = false,
    this.friendInvites = const <BodyDoubleInvite>[],
    this.gentlePrompt =
        'I’m here with you. No pressure — just the next tiny step.',
    this.messages = const <BodyDoubleMessage>[],
    this.participants = const <BodyDoubleParticipant>[],
    this.participantPresences = const <String, String>{},
    this.participantSteps = const <String, int>{},
    this.queueId,
    this.randomSafetyNotice,
    this.eligibility,
    this.speakingParticipantIds = const {},
    this.dopeiSummaryNote,
  });

  final BodyDoubleSession? activeSession;
  final BodyDoubleSession? lastSummary;
  final String? currentStepText;
  final DateTime? nextCheckInAt;
  final int? remainingSeconds;
  final bool checkInDue;
  final List<BodyDoubleInvite> friendInvites;
  final String gentlePrompt;
  final List<BodyDoubleMessage> messages;
  final List<BodyDoubleParticipant> participants;
  final Map<String, String> participantPresences;
  final Map<String, int> participantSteps;
  final String? queueId;
  final String? randomSafetyNotice;
  final RandomBodyDoubleEligibility? eligibility;
  final Set<String> speakingParticipantIds;
  final String? dopeiSummaryNote;

  bool get isActive => activeSession?.status == BodyDoubleStatus.active;
  BodyDoubleSession? get session => activeSession;

  BodyDoubleState copyWith({
    BodyDoubleSession? activeSession,
    BodyDoubleSession? lastSummary,
    String? currentStepText,
    DateTime? nextCheckInAt,
    int? remainingSeconds,
    bool? checkInDue,
    List<BodyDoubleInvite>? friendInvites,
    String? gentlePrompt,
    List<BodyDoubleMessage>? messages,
    List<BodyDoubleParticipant>? participants,
    Map<String, String>? participantPresences,
    Map<String, int>? participantSteps,
    String? queueId,
    String? randomSafetyNotice,
    RandomBodyDoubleEligibility? eligibility,
    Set<String>? speakingParticipantIds,
    String? dopeiSummaryNote,
    bool clearActiveSession = false,
  }) {
    return BodyDoubleState(
      activeSession:
          clearActiveSession ? null : (activeSession ?? this.activeSession),
      lastSummary: lastSummary ?? this.lastSummary,
      currentStepText: currentStepText ?? this.currentStepText,
      nextCheckInAt: nextCheckInAt ?? this.nextCheckInAt,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      checkInDue: checkInDue ?? this.checkInDue,
      friendInvites: friendInvites ?? this.friendInvites,
      gentlePrompt: gentlePrompt ?? this.gentlePrompt,
      messages: messages ?? this.messages,
      participants: participants ?? this.participants,
      participantPresences: participantPresences ?? this.participantPresences,
      participantSteps: participantSteps ?? this.participantSteps,
      queueId: queueId ?? this.queueId,
      randomSafetyNotice: randomSafetyNotice ?? this.randomSafetyNotice,
      eligibility: eligibility ?? this.eligibility,
      speakingParticipantIds:
          speakingParticipantIds ?? this.speakingParticipantIds,
      dopeiSummaryNote: dopeiSummaryNote ?? this.dopeiSummaryNote,
    );
  }
}

final bodyDoubleControllerProvider =
    StateNotifierProvider<BodyDoubleController, BodyDoubleState>((ref) {
  final client = ref.watch(supabaseProvider);
  return BodyDoubleController(
    BodyDoubleRepositoryImpl(
      localStore: ref.watch(localBodyDoubleStoreProvider),
      client: client,
      userId: client?.auth.currentUser?.id,
    ),
    ref,
  );
});

class BodyDoubleController extends StateNotifier<BodyDoubleState> {
  BodyDoubleController(this._repository, this._ref)
      : super(const BodyDoubleState());

  static const int dopeiCompletionXp = 15;

  final BodyDoubleRepositoryImpl _repository;
  final Ref _ref;
  RealtimeChannel? _syncChannel;

  @override
  void dispose() {
    _syncChannel?.unsubscribe();
    super.dispose();
  }

  void _subscribeToSession(String sessionId) {
    final client = _repository.client;
    if (client == null) return;

    // Fetch initial participants
    _fetchParticipants(sessionId);

    _syncChannel?.unsubscribe();
    _syncChannel =
        client.channel('public:body_double_sync:session_id=eq.$sessionId')
          ..onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'body_double_messages',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'session_id',
              value: sessionId,
            ),
            callback: (payload) {
              final json = payload.newRecord;
              final msg = BodyDoubleMessage.fromJson(json);
              state = state.copyWith(
                messages: <BodyDoubleMessage>[...state.messages, msg],
              );

              // Track remote steps via preset signals
              if (msg.messageType == 'preset' &&
                  msg.body == 'Step done' &&
                  msg.senderId != _repository.userId) {
                final current = state.participantSteps[msg.senderId] ?? 0;
                state = state.copyWith(
                  participantSteps: <String, int>{
                    ...state.participantSteps,
                    msg.senderId: current + 1,
                  },
                );
              }
            },
          )
          ..onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'body_double_presence',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'session_id',
              value: sessionId,
            ),
            callback: (payload) {
              final json = payload.newRecord;
              final userId = json['user_id'] as String;
              final status = json['status'] as String?;
              final steps = json['steps_completed'] as int? ?? 0;
              if (userId != _repository.userId) {
                state = state.copyWith(
                  participantPresences: <String, String>{
                    ...state.participantPresences,
                    userId: status ?? 'offline',
                  },
                  participantSteps: <String, int>{
                    ...state.participantSteps,
                    userId: steps,
                  },
                );
              }
            },
          )
          ..subscribe();
  }

  void _subscribeToQueue(String queueId) {
    final client = _repository.client;
    if (client == null) return;
    _syncChannel?.unsubscribe();
    _syncChannel = client.channel('public:body_double_queue:id=eq.$queueId')
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'body_double_queue',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id',
          value: queueId,
        ),
        callback: (payload) async {
          final json = payload.newRecord;
          if (json['status'] == 'matched' &&
              json['matched_session_id'] != null) {
            final sessionId = json['matched_session_id'] as String;
            final res = await client
                .from('body_double_sessions')
                .select()
                .eq('id', sessionId)
                .maybeSingle();
            if (res != null) {
              final matchedSession = BodyDoubleSession.fromJson(res);
              await _repository.saveActiveSession(matchedSession);
              state =
                  state.copyWith(activeSession: matchedSession, queueId: null);
              _subscribeToSession(matchedSession.id);
            }
          }
        },
      )
      ..subscribe();
  }

  Future<void> sendChatMessage(String text) async {
    final session = state.activeSession;
    final client = _repository.client;
    final userId = _repository.userId;
    if (session == null || text.trim().isEmpty) {
      return;
    }
    if (session.mode == BodyDoubleMode.random) {
      if (session.communicationMode == BodyDoubleCommunicationMode.textOnly) {
        final error = await _repository.sendRandomTextMessage(
          sessionId: session.id,
          text: text,
        );
        state = state.copyWith(
          randomSafetyNotice: error ??
              'Limited text sent. Messages are filtered, audited, and reportable.',
          gentlePrompt: error ?? state.gentlePrompt,
        );
        return;
      }
      await sendPresetSignal(_presetSignalForBody(text));
      return;
    }

    if (client == null || userId == null) {
      return;
    }

    try {
      await client.from('body_double_messages').insert(<String, dynamic>{
        'session_id': session.id,
        'sender_id': userId,
        'message_type': 'text',
        'body': text.trim(),
      });
    } catch (e) {
      // Ignore
    }
  }

  Future<void> sendPresetSignal(BodyDoubleSignalType signalType) async {
    final session = state.activeSession;
    final client = _repository.client;
    final userId = _repository.userId;
    if (session == null || client == null || userId == null) return;
    final body = _signalBody(signalType);

    try {
      await client.from('body_double_messages').insert(<String, dynamic>{
        'session_id': session.id,
        'sender_id': userId,
        'message_type': 'preset',
        'body': body,
      });
      await _repository.saveSignal(BodyDoubleSignal(
        id: 'bds-${DateTime.now().microsecondsSinceEpoch}',
        sessionId: session.id,
        userId: userId,
        signalType: signalType,
        createdAt: DateTime.now(),
      ));
    } catch (_) {
      // Remote preset signals are best-effort; safety is enforced server-side.
    }
  }

  Future<void> _addParticipant(
      String sessionId, String role, String status, String privacyLevel) async {
    final client = _repository.client;
    final userId = _repository.userId;
    if (client == null || userId == null) return;
    try {
      await client.from('body_double_participants').upsert(<String, dynamic>{
        'session_id': sessionId,
        'user_id': userId,
        'role': role,
        'status': status,
        'privacy_level': privacyLevel,
      });
    } catch (e) {
      // Ignore
    }
  }

  Future<void> updatePresence(String status) async {
    final session = state.activeSession;
    final client = _repository.client;
    final userId = _repository.userId;
    if (session == null || client == null || userId == null) return;

    try {
      await client.from('body_double_presence').upsert(<String, dynamic>{
        'session_id': session.id,
        'user_id': userId,
        'status': status,
        'steps_completed': session.stepsCompleted,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'session_id,user_id');
    } catch (e) {
      // Ignore
    }
  }

  Future<void> _fetchParticipants(String sessionId) async {
    final client = _repository.client;
    if (client == null) return;
    try {
      final res = await client
          .from('body_double_participants')
          .select()
          .eq('session_id', sessionId);
      final participants = (res as List<dynamic>)
          .map((row) =>
              BodyDoubleParticipant.fromJson(Map<String, dynamic>.from(row)))
          .toList();
      state = state.copyWith(participants: participants);
    } catch (_) {}
  }

  Future<void> restore() async {
    final active = await _repository.loadActiveSession();
    final summary = await _repository.loadLastSummary();
    final invites = await _repository.loadFriendInvites();
    state = state.copyWith(
      activeSession: active,
      lastSummary: summary,
      nextCheckInAt: active == null ? null : _nextCheckInFor(active),
      remainingSeconds: active == null ? null : _remainingSecondsFor(active),
      friendInvites: invites,
    );
    if (active != null && active.mode == BodyDoubleMode.friend) {
      _subscribeToSession(active.id);
      await updatePresence('online');
    }
  }

  Future<void> debugSetActiveSessionForTest(BodyDoubleSession session) async {
    await _repository.saveActiveSession(session);
    state = state.copyWith(activeSession: session);
  }

  Future<void> createFriendInvite({
    required String senderId,
    required String receiverId,
    String? taskId,
    String? taskTitle,
    BodyDoublePrivacyLevel privacyLevel = BodyDoublePrivacyLevel.titleOnly,
    bool isSpurAOn = false,
    int expiresInMinutes = 60,
  }) async {
    final now = DateTime.now();

    // Reuse existing waiting friend session if it matches the task
    BodyDoubleSession? session = state.activeSession;
    if (session != null &&
        session.mode == BodyDoubleMode.friend &&
        session.status == BodyDoubleStatus.waiting &&
        session.taskId == taskId) {
      // Use existing session
    } else {
      session = BodyDoubleSession(
        id: 'bd-friend-${now.microsecondsSinceEpoch}',
        mode: BodyDoubleMode.friend,
        status: BodyDoubleStatus.waiting,
        sessionType: BodyDoubleSessionType.focusSprint,
        taskId: taskId,
        taskTitle: taskTitle,
        startedAt: now,
        communicationMode: BodyDoubleCommunicationMode.quiet,
        privacyLevel: privacyLevel,
        quietMode: true,
        textOnlyMode: true,
      );
      await _repository.saveActiveSession(session);
      await _addParticipant(session.id, 'host', 'joined', privacyLevel.name);
    }

    final invite = BodyDoubleInvite(
      id: 'bdi-${now.microsecondsSinceEpoch}',
      sessionId: session.id,
      senderId: senderId,
      receiverId: receiverId,
      status: BodyDoubleInviteStatus.pending,
      expiresAt: now.add(Duration(minutes: expiresInMinutes)),
      createdAt: now,
      isSpurAOn: isSpurAOn,
    );

    await _repository.saveFriendInvite(invite);

    state = state.copyWith(
      activeSession: session,
      friendInvites: <BodyDoubleInvite>[...state.friendInvites, invite],
      gentlePrompt: isSpurAOn
          ? 'Spur-a-on invite sent. They can offer extra encouragement if they accept.'
          : 'Invite sent. The shared session starts only if they accept.',
    );
  }

  Future<void> respondToFriendInvite({
    required String inviteId,
    required bool accept,
  }) async {
    BodyDoubleInvite? invite;
    for (final item in state.friendInvites) {
      if (item.id == inviteId) {
        invite = item;
        break;
      }
    }
    if (invite == null) return;
    final updated = invite.copyWith(
      status: accept
          ? BodyDoubleInviteStatus.accepted
          : BodyDoubleInviteStatus.declined,
      respondedAt: DateTime.now(),
    );
    await _repository.saveFriendInvite(updated);
    final acceptedSession = accept
        ? state.activeSession?.copyWith(status: BodyDoubleStatus.active)
        : state.activeSession;
    if (accept && acceptedSession != null) {
      await _repository.saveActiveSession(acceptedSession);
      _subscribeToSession(acceptedSession.id);
      await updatePresence('online');
      await _addParticipant(acceptedSession.id, 'friend', 'joined',
          acceptedSession.privacyLevel.name);
    }
    state = state.copyWith(
      friendInvites: <BodyDoubleInvite>[
        for (final item in state.friendInvites)
          if (item.id == inviteId) updated else item,
      ],
      activeSession: acceptedSession,
      gentlePrompt: accept
          ? 'Consent confirmed. You can work quietly together.'
          : 'Invite declined. No pressure, no problem.',
    );
  }

  Future<void> startDopeiSession({
    required BodyDoubleSessionType sessionType,
    String? taskId,
    String? taskTitle,
    String? goal,
    int? sessionLengthMinutes,
    int? checkInIntervalMinutes,
    bool quietMode = true,
    bool textOnlyMode = false,
    bool voiceEnabled = false,
    String? currentStepText,
  }) async {
    final communicationMode = voiceEnabled && !textOnlyMode
        ? BodyDoubleCommunicationMode.voice
        : BodyDoubleCommunicationMode.quiet;
    final session = BodyDoubleSession(
      id: 'bd-${DateTime.now().microsecondsSinceEpoch}',
      mode: BodyDoubleMode.dopei,
      status: BodyDoubleStatus.active,
      sessionType: sessionType,
      taskId: taskId,
      taskTitle: taskTitle,
      goal: goal,
      startedAt: DateTime.now(),
      sessionLengthMinutes: sessionLengthMinutes ?? sessionType.defaultMinutes,
      communicationMode: communicationMode,
      privacyLevel: BodyDoublePrivacyLevel.private,
      checkInIntervalMinutes:
          checkInIntervalMinutes ?? sessionType.defaultCheckInMinutes,
      quietMode: quietMode,
      textOnlyMode: textOnlyMode,
      voiceEnabled: voiceEnabled,
    );
    await _repository.saveActiveSession(session);
    state = state.copyWith(
      activeSession: session,
      currentStepText: currentStepText,
      nextCheckInAt: _nextCheckInFor(session),
      remainingSeconds: _remainingSecondsFor(session),
      checkInDue: false,
      gentlePrompt: _promptFor(sessionType),
    );
  }

  Future<void> pauseSession() async {
    final session = state.activeSession;
    if (session == null || session.status != BodyDoubleStatus.active) return;
    final updated = session.copyWith(status: BodyDoubleStatus.paused);
    await _repository.saveActiveSession(updated);
    state = state.copyWith(
      activeSession: updated,
      checkInDue: false,
      gentlePrompt: 'Paused. No rush — come back when you’re ready.',
    );
  }

  Future<void> resumeSession() async {
    final session = state.activeSession;
    if (session == null || session.status != BodyDoubleStatus.paused) return;
    final updated = session.copyWith(status: BodyDoubleStatus.active);
    await _repository.saveActiveSession(updated);
    state = state.copyWith(
      activeSession: updated,
      nextCheckInAt: _nextCheckInFor(updated),
      checkInDue: false,
      gentlePrompt: 'Back with you. Pick up with one tiny next step.',
    );
  }

  Future<void> refreshSessionClock({DateTime? now}) async {
    final session = state.activeSession;
    if (session == null || session.status != BodyDoubleStatus.active) return;
    final currentTime = now ?? DateTime.now();
    final remainingSeconds = _remainingSecondsFor(session, now: currentTime);
    final nextCheckIn = state.nextCheckInAt ?? _nextCheckInFor(session);
    if (session.sessionLengthMinutes != null && (remainingSeconds ?? 0) <= 0) {
      await endSession();
      return;
    }
    final checkInDue = !currentTime.isBefore(nextCheckIn);
    state = state.copyWith(
      remainingSeconds: remainingSeconds,
      checkInDue: checkInDue,
      gentlePrompt: checkInDue
          ? 'Still with me? No need to answer out loud — just notice the next tiny move.'
          : state.gentlePrompt,
    );
  }

  void acknowledgeCheckIn({DateTime? now}) {
    final session = state.activeSession;
    if (session == null) return;
    final currentTime = now ?? DateTime.now();
    state = state.copyWith(
      nextCheckInAt: currentTime.add(
        Duration(minutes: session.checkInIntervalMinutes),
      ),
      checkInDue: false,
      gentlePrompt: 'Still here counts. Keep it small and steady.',
    );
  }

  Future<void> markStepCompleted() async {
    final session = state.activeSession;
    if (session == null) return;

    final updated = session.copyWith(
      stepsCompleted: session.stepsCompleted + 1,
    );
    await _repository.saveActiveSession(updated);

    String? nextStepText = state.currentStepText;

    // FIX: Also complete the step in the main TaskController if applicable
    try {
      final taskController = _ref.read(taskControllerProvider.notifier);
      await taskController.completeNextStep();

      // Update the local currentStepText from the task controller
      final taskState = _ref.read(taskControllerProvider);
      final nextStep = taskState.steps.firstWhere(
        (s) => s.status != StepStatus.completed && s.depthLevel > 0,
        orElse: () => taskState.steps.first,
      );
      nextStepText = nextStep.text;
    } catch (e) {
      // TaskController might not be active or in a state to complete a step
    }

    if (session.mode == BodyDoubleMode.random) {
      await sendPresetSignal(BodyDoubleSignalType.stepDone);
    }
    await updatePresence('online');
    state = state.copyWith(
      activeSession: updated,
      currentStepText: nextStepText,
      checkInDue: false,
      nextCheckInAt: _nextCheckInFor(updated),
      gentlePrompt: 'Nice. Let that count. Ready for one more tiny step?',
    );
  }

  Future<void> recordOverwhelm() async {
    final session = state.activeSession;
    if (session == null) return;
    final updated = session.copyWith(
      overwhelmEvents: session.overwhelmEvents + 1,
    );
    await _repository.saveActiveSession(updated);
    state = state.copyWith(
      activeSession: updated,
      checkInDue: false,
      nextCheckInAt: _nextCheckInFor(updated),
      gentlePrompt:
          'Let’s shrink this. What is the smallest visible next move?',
    );
  }

  Future<void> endSession(
      {BodyDoubleStatus status = BodyDoubleStatus.completed}) async {
    final session = state.activeSession;
    if (session == null) return;
    final ended = session.copyWith(
      status: status,
      endedAt: DateTime.now(),
      summary: _summaryFor(session, status),
    );
    await _repository.saveSummary(ended);
    await _awardCompletionXp(ended);
    state = state.copyWith(
      lastSummary: ended,
      clearActiveSession: true,
      gentlePrompt:
          'Session finished. You can come back whenever you need presence.',
    );
    _syncChannel?.unsubscribe();
    try {
      final client = _repository.client;
      final userId = _repository.userId;
      if (client != null && userId != null) {
        await client
            .from('body_double_participants')
            .update(<String, dynamic>{'status': 'left'})
            .eq('session_id', session.id)
            .eq('user_id', userId);
      }
    } catch (_) {}
  }

  Future<void> removeParticipant() async {
    final session = state.activeSession;
    final client = _repository.client;
    final userId = _repository.userId;
    if (session == null || client == null || userId == null) return;
    try {
      await client
          .from('body_double_participants')
          .update(<String, dynamic>{'status': 'removed'})
          .eq('session_id', session.id)
          .neq('user_id', userId);
    } catch (_) {}
    await endSession(status: BodyDoubleStatus.cancelled);
  }

  Future<void> emergencyExit() =>
      endSession(status: BodyDoubleStatus.cancelled);

  Future<void> _awardCompletionXp(BodyDoubleSession session) async {
    if (session.mode != BodyDoubleMode.dopei ||
        session.status != BodyDoubleStatus.completed) {
      return;
    }

    try {
      final rewardStore = _ref.read(localRewardStoreProvider);
      await rewardStore.awardXp(
        userId: _repository.userId ?? 'local_user',
        amount: dopeiCompletionXp + session.stepsCompleted * 5,
        key: 'body_double_dopei_completed',
        sourceType: 'body_double_session',
        sourceId: session.id,
      );
    } catch (_) {
      // Rewards are motivating but must never block ending a support session.
    }
  }

  static DateTime _nextCheckInFor(BodyDoubleSession session) {
    return DateTime.now()
        .add(Duration(minutes: session.checkInIntervalMinutes));
  }

  static int? _remainingSecondsFor(BodyDoubleSession session, {DateTime? now}) {
    final length = session.sessionLengthMinutes;
    if (length == null) return null;
    final elapsed =
        (now ?? DateTime.now()).difference(session.startedAt).inSeconds;
    return (length * 60 - elapsed).clamp(0, 1 << 31);
  }

  static String _promptFor(BodyDoubleSessionType type) {
    switch (type) {
      case BodyDoubleSessionType.quickStart:
        return 'I’ll sit with you for five minutes. Start anywhere tiny.';
      case BodyDoubleSessionType.focusSprint:
        return 'Quiet focus. I’ll check in gently, not nag.';
      case BodyDoubleSessionType.choreBuddy:
        return 'One practical step at a time. I’m right here.';
      case BodyDoubleSessionType.calmSupport:
        return 'No timer pressure. We can just stay with it.';
      case BodyDoubleSessionType.overwhelmMode:
        return 'Nothing huge. We only need the smallest possible next step.';
    }
  }

  static String _summaryFor(
      BodyDoubleSession session, BodyDoubleStatus status) {
    if (status == BodyDoubleStatus.cancelled) {
      return 'You left the session safely. That is always allowed.';
    }
    if (session.stepsCompleted == 0) {
      if (session.mode == BodyDoubleMode.friend) {
        return 'You and your friend showed up. That still counts as activation.';
      }
      return 'You showed up for the task. That still counts as activation.';
    }
    if (session.mode == BodyDoubleMode.friend) {
      return 'You completed ${session.stepsCompleted} step${session.stepsCompleted == 1 ? '' : 's'} with your friend.';
    }
    return 'You completed ${session.stepsCompleted} step${session.stepsCompleted == 1 ? '' : 's'} with calm support.';
  }

  Future<void> enterRandomQueue({
    required BodyDoubleSessionType sessionType,
    BodyDoublePrivacyLevel privacyLevel = BodyDoublePrivacyLevel.titleOnly,
    String taskCategory = 'general',
    int? sessionLengthMinutes,
    BodyDoubleCommunicationMode communicationMode =
        BodyDoubleCommunicationMode.presetSignals,
    String language = 'en',
    String? timezone,
  }) async {
    final client = _repository.client;
    final userId = _repository.userId;
    if (client == null || userId == null) return;

    final eligibility = await _repository.loadRandomEligibility();
    if (eligibility == null ||
        !eligibility.canEnterRandomQueue ||
        !eligibility.allowsCommunicationMode(communicationMode)) {
      state = state.copyWith(
        randomSafetyNotice:
            'Random body doubling is off unless trusted profile safety settings allow it. Minors need guardian approval and quiet/preset mode only.',
        gentlePrompt:
            'Safety first. Dope-i can body-double with you right now.',
      );
      return;
    }

    final safeLength = sessionLengthMinutes ?? sessionType.defaultMinutes ?? 25;

    final requested = BodyDoubleQueueEntry(
      id: 'pending',
      userId: userId,
      ageBand: eligibility.ageBand,
      taskCategory: taskCategory,
      sessionLengthMinutes: safeLength,
      communicationMode: communicationMode,
      status: BodyDoubleStatus.waiting,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(minutes: 10)),
      guardianApproved: eligibility.guardianApproved,
      randomMatchingEnabled: eligibility.randomMatchingEnabled,
    );

    if (!requested.canEnterRandomQueue) {
      state = state.copyWith(
        randomSafetyNotice:
            'Random body doubling is off unless safety settings allow it. Minors need guardian approval and preset/quiet mode only.',
        gentlePrompt:
            'Safety first. Dope-i can body-double with you right now.',
      );
      return;
    }

    final now = DateTime.now();

    try {
      final queueId = await _repository.enterRandomQueue(
        sessionType: sessionType,
        taskCategory: taskCategory,
        sessionLengthMinutes: requested.sessionLengthMinutes,
        communicationMode: communicationMode,
        privacyLevel: privacyLevel,
      );
      if (queueId == null || queueId.isEmpty) {
        state = state.copyWith(
          randomSafetyNotice:
              'Could not enter the random queue. Check random matching settings or try Dope-i body doubling.',
        );
        return;
      }

      // Dummy session so UI knows we're waiting
      final session = BodyDoubleSession(
        id: queueId,
        mode: BodyDoubleMode.random,
        status: BodyDoubleStatus.waiting,
        sessionType: sessionType,
        startedAt: now,
        sessionLengthMinutes: requested.sessionLengthMinutes,
        communicationMode: communicationMode,
        privacyLevel: privacyLevel,
        quietMode: true,
        textOnlyMode: communicationMode == BodyDoubleCommunicationMode.textOnly,
      );

      await _repository.saveActiveSession(session);

      state = state.copyWith(
        activeSession: session,
        queueId: queueId,
        gentlePrompt: 'Looking for a safe anonymous focus partner...',
        randomSafetyNotice: communicationMode ==
                BodyDoubleCommunicationMode.textOnly
            ? 'Anonymous adult-only limited text. No links, contact details, locations, voice, video, profiles, or contact exchange. You can leave/report anytime.'
            : 'Anonymous only. No names, photos, free chat, voice, video, profiles, or contact exchange. You can leave anytime.',
      );

      _subscribeToQueue(queueId);

      // Attempt to find a match via RPC
      try {
        await client
            .rpc('find_body_double_match', params: {'p_queue_id': queueId});
      } catch (_) {}
    } catch (e) {
      state = state.copyWith(
        randomSafetyNotice:
            'Could not enter the random queue. Dope-i body doubling is still available.',
      );
    }
  }

  Future<void> reportParticipant(String reason, String details) async {
    final session = state.activeSession;
    final client = _repository.client;
    final userId = _repository.userId;
    if (session == null || client == null || userId == null) return;

    try {
      // Find the other user
      final participants = await client
          .from('body_double_participants')
          .select('user_id')
          .eq('session_id', session.id)
          .neq('user_id', userId);

      if (participants.isNotEmpty) {
        final reportedId = participants.first['user_id'] as String;

        await _repository.reportRandomSession(
          sessionId: session.id,
          reportedUserId: reportedId,
          reason: reason,
          details: details,
        );
      }
    } catch (_) {}

    await emergencyExit();
  }

  Future<void> cancelRandomQueue() async {
    final queueId = state.queueId;
    if (queueId != null) {
      await _repository.cancelRandomQueue(queueId);
    }
    await emergencyExit();
  }

  static BodyDoubleSignalType _presetSignalForBody(String body) {
    switch (body.trim()) {
      case 'I’m starting':
        return BodyDoubleSignalType.started;
      case 'Step done':
      case 'Completed a step!':
        return BodyDoubleSignalType.stepDone;
      case 'Taking a short break':
        return BodyDoubleSignalType.breakStart;
      case 'Back now':
        return BodyDoubleSignalType.breakEnd;
      case 'Wrapping up':
        return BodyDoubleSignalType.wrappingUp;
      case 'Thanks':
        return BodyDoubleSignalType.thanks;
      case 'Shared "still here"':
      case 'Still here':
      default:
        return BodyDoubleSignalType.stillHere;
    }
  }

  static String _signalBody(BodyDoubleSignalType signalType) {
    switch (signalType) {
      case BodyDoubleSignalType.started:
        return 'I’m starting';
      case BodyDoubleSignalType.stillHere:
        return 'Still here';
      case BodyDoubleSignalType.stepDone:
        return 'Step done';
      case BodyDoubleSignalType.breakStart:
        return 'Taking a short break';
      case BodyDoubleSignalType.breakEnd:
        return 'Back now';
      case BodyDoubleSignalType.wrappingUp:
        return 'Wrapping up';
      case BodyDoubleSignalType.thanks:
        return 'Thanks';
      case BodyDoubleSignalType.left:
        return 'Wrapping up';
    }
  }

  void setSpeaking(bool speaking) {
    final userId = _repository.userId;
    if (userId == null) return;
    state = state.copyWith(
      speakingParticipantIds: speaking
          ? <String>{...state.speakingParticipantIds, userId}
          : <String>{...state.speakingParticipantIds}
        ..remove(userId),
    );
  }

  Future<void> blockParticipant(String targetUserId) async {
    final client = _ref.read(supabaseProvider);
    if (client == null) return;

    try {
      await client.from('user_blocks').insert({
        'blocker_id': client.auth.currentUser?.id,
        'blocked_id': targetUserId,
      });
    } catch (e) {
      // Block insert is best-effort; user may not be signed in
    }
  }

  Future<void> finishSession({required bool completed}) async {
    final session = state.activeSession;
    if (session == null) return;

    final userId = _repository.userId;
    if (userId != null) {
      await _repository.updateReliabilityScore(
          userId: userId, completed: completed);
    }

    final note = await _repository.getDopeiSummaryNote(
      stepsCompleted: state.participantSteps[userId] ?? 0,
      totalMinutes: 25,
    );

    state = state.copyWith(dopeiSummaryNote: note);
  }
}
