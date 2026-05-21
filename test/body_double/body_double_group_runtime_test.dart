import 'package:dope_i_mine/data/local/local_body_double_store.dart';
import 'package:dope_i_mine/data/local/local_json_store.dart';
import 'package:dope_i_mine/data/repositories/body_double_repository_impl.dart';
import 'package:dope_i_mine/domain/body_double/body_double_session.dart';
import 'package:dope_i_mine/presentation/body_double/body_double_controller.dart';
import 'package:dope_i_mine/presentation/body_double/friend_body_double_session_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('random group queue is adult-only, restricted-safe, and capped', () {
    final now = DateTime.now();
    final adult = BodyDoubleQueueEntry(
      id: 'adult-group',
      userId: 'adult-1',
      ageBand: BodyDoubleAgeBand.adult,
      taskCategory: 'focus',
      sessionLengthMinutes: 25,
      communicationMode: BodyDoubleCommunicationMode.presetSignals,
      status: BodyDoubleStatus.waiting,
      createdAt: now,
      expiresAt: now.add(const Duration(minutes: 10)),
      randomMatchingEnabled: true,
      wantsGroupSession: true,
      maxGroupSize: BodyDoubleGroupPolicy.maximumParticipants,
    );
    final minor = BodyDoubleQueueEntry(
      id: 'minor-group',
      userId: 'teen-1',
      ageBand: BodyDoubleAgeBand.teen,
      taskCategory: 'study',
      sessionLengthMinutes: 25,
      communicationMode: BodyDoubleCommunicationMode.presetSignals,
      status: BodyDoubleStatus.waiting,
      createdAt: now,
      expiresAt: now.add(const Duration(minutes: 10)),
      randomMatchingEnabled: true,
      wantsGroupSession: true,
      maxGroupSize: BodyDoubleGroupPolicy.maximumParticipants,
    );
    final restricted = BodyDoubleQueueEntry(
      id: 'restricted-group',
      userId: 'adult-2',
      ageBand: BodyDoubleAgeBand.adult,
      taskCategory: 'focus',
      sessionLengthMinutes: 25,
      communicationMode: BodyDoubleCommunicationMode.presetSignals,
      status: BodyDoubleStatus.waiting,
      createdAt: now,
      expiresAt: now.add(const Duration(minutes: 10)),
      randomMatchingEnabled: true,
      wantsGroupSession: true,
      restricted: true,
    );

    expect(adult.canEnterRandomGroupQueue, isTrue);
    expect(minor.canEnterRandomGroupQueue, isFalse);
    expect(restricted.canEnterRandomGroupQueue, isFalse);
    expect(BodyDoubleGroupPolicy.maximumParticipants, 3);
  });

  test('random group compatibility blocks duplicates, full groups, and blocks',
      () {
    final now = DateTime.now();
    final session = BodyDoubleSession(
      id: 'group-1',
      mode: BodyDoubleMode.randomGroup,
      status: BodyDoubleStatus.active,
      sessionType: BodyDoubleSessionType.focusSprint,
      startedAt: now,
      sessionLengthMinutes: 25,
      communicationMode: BodyDoubleCommunicationMode.presetSignals,
      privacyLevel: BodyDoublePrivacyLevel.titleOnly,
      maxParticipants: 3,
      currentParticipantCount: 2,
    );
    final participants = <BodyDoubleParticipant>[
      BodyDoubleParticipant(
        id: 'p1',
        sessionId: 'group-1',
        userId: 'adult-1',
        role: 'host',
        status: BodyDoubleParticipantStatus.active,
        anonymousLabel: 'Body double 1',
      ),
      BodyDoubleParticipant(
        id: 'p2',
        sessionId: 'group-1',
        userId: 'adult-2',
        role: 'participant',
        status: BodyDoubleParticipantStatus.active,
        anonymousLabel: 'Body double 2',
      ),
    ];
    BodyDoubleQueueEntry queue(
            {String userId = 'adult-3', Set<String> blocks = const {}}) =>
        BodyDoubleQueueEntry(
          id: 'queue-$userId',
          userId: userId,
          ageBand: BodyDoubleAgeBand.adult,
          taskCategory: 'focus',
          sessionLengthMinutes: 25,
          communicationMode: BodyDoubleCommunicationMode.presetSignals,
          status: BodyDoubleStatus.waiting,
          createdAt: now,
          expiresAt: now.add(const Duration(minutes: 10)),
          randomMatchingEnabled: true,
          wantsGroupSession: true,
          maxGroupSize: 3,
          blockedUserIds: blocks,
        );

    expect(
        queue()
            .canJoinRandomGroup(participants: participants, session: session),
        isTrue);
    expect(
        queue(userId: 'adult-1')
            .canJoinRandomGroup(participants: participants, session: session),
        isFalse);
    expect(
        queue(blocks: {'adult-2'})
            .canJoinRandomGroup(participants: participants, session: session),
        isFalse);
    expect(
        queue().canJoinRandomGroup(
          participants: participants,
          session: session.copyWith(currentParticipantCount: 3),
        ),
        isFalse);
  });

  test('known group invite flow requires trusted participant ids', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final controller = await _controller();

    final blocked = await controller.createKnownGroupInvites(
      senderId: 'host-1',
      receiverIds: const <String>['stranger-1'],
      allowedReceiverIds: const <String>{'trusted-1'},
    );
    expect(blocked, isFalse);
    expect(controller.state.gentlePrompt, contains('accepted trusted'));

    final sent = await controller.createKnownGroupInvites(
      senderId: 'host-1',
      receiverIds: const <String>['trusted-1', 'trusted-2', 'trusted-3'],
      allowedReceiverIds: const <String>{'trusted-1', 'trusted-2', 'trusted-3'},
    );
    expect(sent, isTrue);
    expect(controller.state.activeSession!.mode, BodyDoubleMode.knownGroup);
    expect(controller.state.activeSession!.maxParticipants, 3);
    expect(controller.state.friendInvites, hasLength(2));
  });

  testWidgets(
      'group session shows participant count, leave, report, and preset signals',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final controller = await _controller();
    await controller.debugSetActiveSessionForTest(BodyDoubleSession(
      id: 'group-widget',
      mode: BodyDoubleMode.randomGroup,
      status: BodyDoubleStatus.active,
      sessionType: BodyDoubleSessionType.focusSprint,
      startedAt: DateTime.now(),
      communicationMode: BodyDoubleCommunicationMode.presetSignals,
      privacyLevel: BodyDoublePrivacyLevel.titleOnly,
      maxParticipants: 3,
      currentParticipantCount: 2,
    ));

    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[
        bodyDoubleControllerProvider.overrideWith((ref) => controller),
      ],
      child: const MaterialApp(home: FriendBodyDoubleSessionScreen()),
    ));
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('group-session-label')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('group-participant-count')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('group-leave-button')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('group-report-button')),
        findsOneWidget);
    await tester.scrollUntilVisible(find.text('Preset signals only'), 300);
    expect(find.text('Preset signals only'), findsOneWidget);
    expect(find.textContaining('Voice active'), findsNothing);
    expect(find.textContaining('Limited random text'), findsNothing);
  });
}

Future<BodyDoubleController> _controller() async {
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer();
  return BodyDoubleController(
    BodyDoubleRepositoryImpl(
      localStore: LocalBodyDoubleStore(
        store: LocalJsonStore('test.body_double.group', preferences: prefs),
      ),
    ),
    container.read(_refProvider),
  );
}

final _refProvider = Provider<Ref>((ref) => ref);
