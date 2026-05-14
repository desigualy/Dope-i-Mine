import 'package:dope_i_mine/data/local/local_body_double_store.dart';
import 'package:dope_i_mine/data/local/local_json_store.dart';
import 'package:dope_i_mine/data/repositories/body_double_repository_impl.dart';
import 'package:dope_i_mine/domain/body_double/body_double_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('repository persists active sessions and summaries without Supabase',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final repository = BodyDoubleRepositoryImpl(
      localStore: LocalBodyDoubleStore(
        store: LocalJsonStore('test.body_double.repository', preferences: prefs),
      ),
    );
    final session = BodyDoubleSession(
      id: 'bd-local-1',
      mode: BodyDoubleMode.dopei,
      status: BodyDoubleStatus.active,
      sessionType: BodyDoubleSessionType.focusSprint,
      startedAt: DateTime(2026, 5, 8, 19),
      sessionLengthMinutes: 25,
      checkInIntervalMinutes: 5,
    );

    await repository.saveActiveSession(session);
    final restored = await repository.loadActiveSession();
    expect(restored, isNotNull);
    expect(restored!.id, 'bd-local-1');
    expect(restored.sessionType, BodyDoubleSessionType.focusSprint);

    final completed = session.copyWith(
      status: BodyDoubleStatus.completed,
      endedAt: DateTime(2026, 5, 8, 19, 25),
      stepsCompleted: 2,
      summary: 'You completed 2 steps with calm support.',
    );
    await repository.saveSummary(completed);

    expect(await repository.loadActiveSession(), isNull);
    final summary = await repository.loadLastSummary();
    expect(summary, isNotNull);
    expect(summary!.status, BodyDoubleStatus.completed);
    expect(summary.stepsCompleted, 2);
  });

  test('repository persists friend invites without Supabase', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final repository = BodyDoubleRepositoryImpl(
      localStore: LocalBodyDoubleStore(
        store: LocalJsonStore(
          'test.body_double.repository.invites',
          preferences: prefs,
        ),
      ),
    );
    final invite = BodyDoubleInvite(
      id: 'invite-1',
      sessionId: 'session-1',
      senderId: 'sender-1',
      receiverId: 'receiver-1',
      status: BodyDoubleInviteStatus.pending,
      expiresAt: DateTime(2026, 5, 8, 20),
      createdAt: DateTime(2026, 5, 8, 19),
    );

    await repository.saveFriendInvite(invite);
    await repository.saveFriendInvite(
      invite.copyWith(
        status: BodyDoubleInviteStatus.accepted,
        respondedAt: DateTime(2026, 5, 8, 19, 5),
      ),
    );

    final invites = await repository.loadFriendInvites();
    expect(invites, hasLength(1));
    expect(invites.single.id, 'invite-1');
    expect(invites.single.status, BodyDoubleInviteStatus.accepted);
    expect(invites.single.respondedAt, isNotNull);
  });
}