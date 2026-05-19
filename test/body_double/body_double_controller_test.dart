import 'package:dope_i_mine/data/local/local_body_double_store.dart';
import 'package:dope_i_mine/data/local/local_json_store.dart';
import 'package:dope_i_mine/data/local/local_reward_store.dart';
import 'package:dope_i_mine/data/repositories/body_double_repository_impl.dart';
import 'package:dope_i_mine/domain/body_double/body_double_session.dart';
import 'package:dope_i_mine/presentation/body_double/body_double_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BodyDoubleController Phase 1', () {
    test('starts Dope-i session with calm defaults', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final controller = await _controller();

      await controller.startDopeiSession(
        sessionType: BodyDoubleSessionType.quickStart,
        taskId: 'task-1',
        taskTitle: 'Clean desk',
        currentStepText: 'Move one cup',
      );

      final session = controller.state.activeSession;
      expect(session, isNotNull);
      expect(session!.mode, BodyDoubleMode.dopei);
      expect(session.status, BodyDoubleStatus.active);
      expect(session.sessionLengthMinutes, 5);
      expect(session.communicationMode, BodyDoubleCommunicationMode.quiet);
      expect(session.privacyLevel, BodyDoublePrivacyLevel.private);
      expect(session.quietMode, isTrue);
      expect(controller.state.currentStepText, 'Move one cup');
    });

    test('records progress and saves summary on completion', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final controller = await _controller();

      await controller.startDopeiSession(
        sessionType: BodyDoubleSessionType.choreBuddy,
        taskId: 'task-1',
        taskTitle: 'Clean desk',
      );
      await controller.markStepCompleted();
      await controller.recordOverwhelm();
      await controller.endSession();

      expect(controller.state.activeSession, isNull);
      expect(controller.state.lastSummary, isNotNull);
      expect(controller.state.lastSummary!.stepsCompleted, 1);
      expect(controller.state.lastSummary!.overwhelmEvents, 1);
      expect(controller.state.lastSummary!.status, BodyDoubleStatus.completed);
      expect(controller.state.lastSummary!.summary, contains('1 step'));
    });

    test('completed Dope-i sessions award local XP idempotently', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final rewardStore = LocalRewardStore(
        store: LocalJsonStore('test.body_double.rewards', preferences: prefs),
      );
      final controller = await _controller(ref: _RewardRef(rewardStore));

      await controller.startDopeiSession(
        sessionType: BodyDoubleSessionType.quickStart,
      );
      await controller.markStepCompleted();
      await controller.endSession();

      expect(
        await rewardStore.currentXp(),
        BodyDoubleController.dopeiCompletionXp + 5,
      );

      // Re-ending/restoring the saved summary must not duplicate XP.
      await controller.restore();
      expect(
        await rewardStore.currentXp(),
        BodyDoubleController.dopeiCompletionXp + 5,
      );
    });

    test('active Dope-i session survives controller recreation', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final firstController = await _controller();

      await firstController.startDopeiSession(
        sessionType: BodyDoubleSessionType.focusSprint,
        taskId: 'task-restore',
        taskTitle: 'Write notes',
        currentStepText: 'Open the document',
      );

      final restoredController = await _controller();
      await restoredController.restore();

      final restored = restoredController.state.activeSession;
      expect(restored, isNotNull);
      expect(restored!.mode, BodyDoubleMode.dopei);
      expect(restored.status, BodyDoubleStatus.active);
      expect(restored.taskId, 'task-restore');
      expect(restored.taskTitle, 'Write notes');
      expect(restoredController.state.remainingSeconds, isNotNull);
    });

    test('emergency exit is always allowed and marked cancelled', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final controller = await _controller();

      await controller.startDopeiSession(
        sessionType: BodyDoubleSessionType.overwhelmMode,
      );
      await controller.emergencyExit();

      expect(controller.state.activeSession, isNull);
      expect(controller.state.lastSummary!.status, BodyDoubleStatus.cancelled);
      expect(controller.state.lastSummary!.summary, contains('safely'));
    });

    test('supports pause, resume, gentle check-ins, and timer completion',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final controller = await _controller();

      await controller.startDopeiSession(
        sessionType: BodyDoubleSessionType.quickStart,
        sessionLengthMinutes: 3,
        checkInIntervalMinutes: 1,
      );
      final session = controller.state.activeSession!;
      expect(controller.state.remainingSeconds, lessThanOrEqualTo(180));

      await controller.refreshSessionClock(
        now: session.startedAt.add(const Duration(seconds: 30)),
      );
      expect(controller.state.remainingSeconds, 150);

      await controller.pauseSession();
      expect(controller.state.activeSession!.status, BodyDoubleStatus.paused);
      expect(controller.state.gentlePrompt, contains('Paused'));

      await controller.resumeSession();
      expect(controller.state.activeSession!.status, BodyDoubleStatus.active);

      await controller.refreshSessionClock(
        now: controller.state.nextCheckInAt!.add(const Duration(seconds: 1)),
      );
      expect(controller.state.checkInDue, isTrue);
      expect(controller.state.gentlePrompt, contains('Still with me'));

      controller.acknowledgeCheckIn();
      expect(controller.state.checkInDue, isFalse);

      await controller.refreshSessionClock(
        now: session.startedAt.add(const Duration(seconds: 181)),
      );
      expect(controller.state.activeSession, isNull);
      expect(controller.state.lastSummary!.status, BodyDoubleStatus.completed);
    });

    test('friend invite waits for consent and respects privacy defaults',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final controller = await _controller();

      await controller.createFriendInvite(
        senderId: 'user-sender',
        receiverId: 'user-friend',
        taskId: 'task-1',
        taskTitle: 'Sort paperwork',
      );

      final session = controller.state.activeSession;
      expect(session, isNotNull);
      expect(session!.mode, BodyDoubleMode.friend);
      expect(session.status, BodyDoubleStatus.waiting);
      expect(session.privacyLevel, BodyDoublePrivacyLevel.titleOnly);
      expect(session.textOnlyMode, isTrue);
      expect(controller.state.friendInvites, hasLength(1));
      expect(controller.state.friendInvites.single.status,
          BodyDoubleInviteStatus.pending);
      expect(controller.state.gentlePrompt, contains('only if they accept'));

      await controller.respondToFriendInvite(
        inviteId: controller.state.friendInvites.single.id,
        accept: true,
      );

      expect(controller.state.activeSession!.status, BodyDoubleStatus.active);
      expect(controller.state.friendInvites.single.status,
          BodyDoubleInviteStatus.accepted);
      expect(controller.state.gentlePrompt, contains('Consent confirmed'));
    });

    test('friend invite can be declined without starting shared session',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final controller = await _controller();

      await controller.createFriendInvite(
        senderId: 'user-sender',
        receiverId: 'user-friend',
        privacyLevel: BodyDoublePrivacyLevel.private,
      );
      await controller.respondToFriendInvite(
        inviteId: controller.state.friendInvites.single.id,
        accept: false,
      );

      expect(controller.state.activeSession!.status, BodyDoubleStatus.waiting);
      expect(controller.state.activeSession!.privacyLevel,
          BodyDoublePrivacyLevel.private);
      expect(controller.state.friendInvites.single.status,
          BodyDoubleInviteStatus.declined);
      expect(controller.state.gentlePrompt, contains('No pressure'));
    });

    test('random queue is opt-in and protects minors from unsafe modes', () {
      final now = DateTime(2026, 5, 8);
      final child = BodyDoubleQueueEntry(
        id: 'queue-child',
        userId: 'child-1',
        ageBand: BodyDoubleAgeBand.child,
        taskCategory: 'homework',
        sessionLengthMinutes: 10,
        communicationMode: BodyDoubleCommunicationMode.presetSignals,
        status: BodyDoubleStatus.waiting,
        createdAt: now,
        expiresAt: now.add(const Duration(minutes: 5)),
      );
      final approvedTeen = BodyDoubleQueueEntry(
        id: 'queue-teen',
        userId: 'teen-1',
        ageBand: BodyDoubleAgeBand.teen,
        taskCategory: 'study',
        sessionLengthMinutes: 25,
        communicationMode: BodyDoubleCommunicationMode.presetSignals,
        status: BodyDoubleStatus.waiting,
        createdAt: now,
        expiresAt: now.add(const Duration(minutes: 5)),
        guardianApproved: true,
        randomMatchingEnabled: true,
      );
      final adult = BodyDoubleQueueEntry(
        id: 'queue-adult',
        userId: 'adult-1',
        ageBand: BodyDoubleAgeBand.adult,
        taskCategory: 'admin',
        sessionLengthMinutes: 25,
        communicationMode: BodyDoubleCommunicationMode.presetSignals,
        status: BodyDoubleStatus.waiting,
        createdAt: now,
        expiresAt: now.add(const Duration(minutes: 5)),
        randomMatchingEnabled: true,
      );
      final approvedTeenText = BodyDoubleQueueEntry(
        id: 'queue-teen-text',
        userId: 'teen-2',
        ageBand: BodyDoubleAgeBand.teen,
        taskCategory: 'study',
        sessionLengthMinutes: 25,
        communicationMode: BodyDoubleCommunicationMode.textOnly,
        status: BodyDoubleStatus.waiting,
        createdAt: now,
        expiresAt: now.add(const Duration(minutes: 5)),
        guardianApproved: true,
        randomMatchingEnabled: true,
      );

      expect(child.canEnterRandomQueue, isFalse);
      expect(approvedTeen.canEnterRandomQueue, isTrue);
      expect(approvedTeenText.canEnterRandomQueue, isFalse);
      expect(adult.canEnterRandomQueue, isTrue);
      expect(approvedTeen.canMatchWith(adult), isFalse);
    });

    test('minor random matching stays age-band exact and preset-only', () {
      final now = DateTime(2026, 5, 9);
      final teenOne = BodyDoubleQueueEntry(
        id: 'queue-teen-1',
        userId: 'teen-1',
        ageBand: BodyDoubleAgeBand.teen,
        taskCategory: 'study',
        sessionLengthMinutes: 25,
        communicationMode: BodyDoubleCommunicationMode.presetSignals,
        status: BodyDoubleStatus.waiting,
        createdAt: now,
        expiresAt: now.add(const Duration(minutes: 10)),
        guardianApproved: true,
        randomMatchingEnabled: true,
      );
      final teenTwo = BodyDoubleQueueEntry(
        id: 'queue-teen-2',
        userId: 'teen-2',
        ageBand: BodyDoubleAgeBand.teen,
        taskCategory: 'study',
        sessionLengthMinutes: 25,
        communicationMode: BodyDoubleCommunicationMode.presetSignals,
        status: BodyDoubleStatus.waiting,
        createdAt: now,
        expiresAt: now.add(const Duration(minutes: 10)),
        guardianApproved: true,
        randomMatchingEnabled: true,
      );
      final preTeen = BodyDoubleQueueEntry(
        id: 'queue-pre-teen',
        userId: 'pre-teen-1',
        ageBand: BodyDoubleAgeBand.preTeen,
        taskCategory: 'study',
        sessionLengthMinutes: 25,
        communicationMode: BodyDoubleCommunicationMode.presetSignals,
        status: BodyDoubleStatus.waiting,
        createdAt: now,
        expiresAt: now.add(const Duration(minutes: 10)),
        guardianApproved: true,
        randomMatchingEnabled: true,
      );
      final teenVoice = BodyDoubleQueueEntry(
        id: 'queue-teen-voice',
        userId: 'teen-3',
        ageBand: BodyDoubleAgeBand.teen,
        taskCategory: 'study',
        sessionLengthMinutes: 25,
        communicationMode: BodyDoubleCommunicationMode.voice,
        status: BodyDoubleStatus.waiting,
        createdAt: now,
        expiresAt: now.add(const Duration(minutes: 10)),
        guardianApproved: true,
        randomMatchingEnabled: true,
      );

      expect(teenOne.canMatchWith(teenTwo), isTrue);
      expect(teenOne.canMatchWith(preTeen), isFalse);
      expect(teenVoice.canEnterRandomQueue, isFalse);
      expect(teenOne.canMatchWith(teenVoice), isFalse);
    });

    test('random safety settings parse safe defaults from remote rows', () {
      final settings = RandomBodyDoubleSafetySettings.fromJson(
        <String, dynamic>{
          'user_id': 'adult-1',
          'random_matching_enabled': true,
          'guardian_random_approved': false,
          'preset_signals_allowed': true,
          'quiet_mode_allowed': true,
          'text_allowed': false,
          'voice_allowed': false,
        },
      );

      expect(settings.userId, 'adult-1');
      expect(settings.randomMatchingEnabled, isTrue);
      expect(settings.guardianRandomApproved, isFalse);
      expect(settings.presetSignalsAllowed, isTrue);
      expect(settings.quietModeAllowed, isTrue);
      expect(settings.textAllowed, isFalse);
      expect(settings.voiceAllowed, isFalse);
    });

    test('random eligibility normalizes legacy preteen age band', () {
      final eligibility = RandomBodyDoubleEligibility.fromJson(
        <String, dynamic>{
          'user_id': 'preteen-1',
          'age_band': 'preteen',
          'random_matching_enabled': true,
          'guardian_approved': true,
          'preset_signals_allowed': true,
          'quiet_mode_allowed': true,
          'text_allowed': false,
          'can_enter_random_queue': true,
        },
      );

      expect(eligibility.ageBand, BodyDoubleAgeBand.preTeen);
      expect(eligibility.canEnterRandomQueue, isTrue);
      expect(
        eligibility.allowsCommunicationMode(
          BodyDoubleCommunicationMode.presetSignals,
        ),
        isTrue,
      );
      expect(
        eligibility.allowsCommunicationMode(BodyDoubleCommunicationMode.voice),
        isFalse,
      );
    });

    test('Phase 3C random text is adult-only and explicitly opted in', () {
      final adult = RandomBodyDoubleEligibility.fromJson(
        <String, dynamic>{
          'user_id': 'adult-1',
          'age_band': 'adult',
          'random_matching_enabled': true,
          'guardian_approved': false,
          'preset_signals_allowed': true,
          'quiet_mode_allowed': true,
          'text_allowed': true,
          'can_enter_random_queue': true,
        },
      );
      final teen = RandomBodyDoubleEligibility.fromJson(
        <String, dynamic>{
          'user_id': 'teen-1',
          'age_band': 'teen',
          'random_matching_enabled': true,
          'guardian_approved': true,
          'preset_signals_allowed': true,
          'quiet_mode_allowed': true,
          'text_allowed': true,
          'can_enter_random_queue': true,
        },
      );

      expect(
          adult.allowsCommunicationMode(BodyDoubleCommunicationMode.textOnly),
          isTrue);
      expect(teen.allowsCommunicationMode(BodyDoubleCommunicationMode.textOnly),
          isFalse);
    });

    test(
        'Phase 3C random text safety blocks links, contact info, and unsafe content',
        () {
      expect(
          RandomBodyDoubleTextSafety.check('Still here, starting step one')
              .isAllowed,
          isTrue);
      expect(
        RandomBodyDoubleTextSafety.check('Visit https://example.com').status,
        RandomBodyDoubleTextSafetyStatus.containsLink,
      );
      expect(
        RandomBodyDoubleTextSafety.check('Email me at person@example.com')
            .status,
        RandomBodyDoubleTextSafetyStatus.containsContactInfo,
      );
      expect(
        RandomBodyDoubleTextSafety.check('Where do you live?').status,
        RandomBodyDoubleTextSafetyStatus.containsLocationRequest,
      );
      expect(
        RandomBodyDoubleTextSafety.check('fuck this').status,
        RandomBodyDoubleTextSafetyStatus.containsUnsafeContent,
      );
    });

    test('repository returns filtered random text feedback before remote send',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final repository = BodyDoubleRepositoryImpl(
        localStore: LocalBodyDoubleStore(
          store: LocalJsonStore('test.body_double.random_text',
              preferences: prefs),
        ),
      );

      final blocked = await repository.sendRandomTextMessage(
        sessionId: 'session-random-text',
        text: 'Message me at person@example.com',
      );
      final safeButOffline = await repository.sendRandomTextMessage(
        sessionId: 'session-random-text',
        text: 'Still here and starting step one',
      );

      expect(blocked, contains('Contact details'));
      expect(safeButOffline, contains('signed-in safe session'));
    });

    test('random text-mode session shows blocked-message feedback', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final controller = await _controller();
      await controller.startDopeiSession(
        sessionType: BodyDoubleSessionType.focusSprint,
      );
      final randomTextSession = BodyDoubleSession(
        id: 'session-random-text-local',
        mode: BodyDoubleMode.random,
        status: BodyDoubleStatus.active,
        sessionType: BodyDoubleSessionType.focusSprint,
        startedAt: DateTime(2026, 5, 10, 18),
        communicationMode: BodyDoubleCommunicationMode.textOnly,
        textOnlyMode: true,
      );

      await controller.endSession(status: BodyDoubleStatus.cancelled);
      await controller.restore();
      await controller.debugSetActiveSessionForTest(randomTextSession);

      await controller.sendChatMessage('Visit https://example.com');

      expect(controller.state.randomSafetyNotice,
          contains('Links are not allowed'));
      expect(controller.state.gentlePrompt, contains('Links are not allowed'));
    });
  });
}

Future<BodyDoubleController> _controller({Ref? ref}) async {
  final prefs = await SharedPreferences.getInstance();
  return BodyDoubleController(
    BodyDoubleRepositoryImpl(
      localStore: LocalBodyDoubleStore(
        store: LocalJsonStore('test.body_double', preferences: prefs),
      ),
    ),
    ref ?? _MockRef(),
  );
}

class _MockRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RewardRef extends _MockRef {
  _RewardRef(this._rewardStore);

  final LocalRewardStore _rewardStore;

  @override
  T read<T>(ProviderListenable<T> provider) {
    if (identical(provider, localRewardStoreProvider)) {
      return _rewardStore as T;
    }
    return super.noSuchMethod(
      Invocation.method(#read, <Object?>[provider]),
    ) as T;
  }
}
