import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/body_double/body_double_session.dart';
import 'local_json_store.dart';

final localBodyDoubleStoreProvider = Provider<LocalBodyDoubleStore>((ref) {
  return LocalBodyDoubleStore();
});

class LocalBodyDoubleStore {
  LocalBodyDoubleStore({LocalJsonStore? store})
      : _store = store ?? LocalJsonStore('dope_i_mine.local.body_double.v1');

  final LocalJsonStore _store;

  static const String _activeKey = 'active_session';
  static const String _summaryKey = 'last_summary';
  static const String _invitesKey = 'friend_invites';
  static const String _participantsKey = 'participants';
  static const String _signalsKey = 'signals';

  Future<void> saveActiveSession(BodyDoubleSession session) async {
    await _store.writeMap(_activeKey, session.toJson());
  }

  Future<BodyDoubleSession?> loadActiveSession() async {
    final json = await _store.readMap(_activeKey);
    if (json == null) return null;
    return BodyDoubleSession.fromJson(json);
  }

  Future<void> clearActiveSession() async {
    await _store.remove(_activeKey);
  }

  Future<void> saveSummary(BodyDoubleSession session) async {
    await _store.writeMap(_summaryKey, session.toJson());
    await clearActiveSession();
  }

  Future<BodyDoubleSession?> loadLastSummary() async {
    final json = await _store.readMap(_summaryKey);
    if (json == null) return null;
    return BodyDoubleSession.fromJson(json);
  }

  Future<void> saveFriendInvite(BodyDoubleInvite invite) async {
    final invites = await loadFriendInvites();
    final updated = <BodyDoubleInvite>[
      for (final existing in invites)
        if (existing.id != invite.id) existing,
      invite,
    ];
    await _store.writeList(
      _invitesKey,
      updated.map((invite) => invite.toJson()).toList(),
    );
  }

  Future<List<BodyDoubleInvite>> loadFriendInvites() async {
    final rows = await _store.readList(_invitesKey);
    return rows.map(BodyDoubleInvite.fromJson).toList();
  }

  Future<void> saveParticipant(BodyDoubleParticipant participant) async {
    final participants = await loadParticipants();
    final updated = <BodyDoubleParticipant>[
      for (final existing in participants)
        if (existing.id != participant.id) existing,
      participant,
    ];
    await _store.writeList(
      _participantsKey,
      updated.map((participant) => participant.toJson()).toList(),
    );
  }

  Future<List<BodyDoubleParticipant>> loadParticipants() async {
    final rows = await _store.readList(_participantsKey);
    return rows.map(BodyDoubleParticipant.fromJson).toList();
  }

  Future<void> saveSignal(BodyDoubleSignal signal) async {
    final signals = await loadSignals();
    await _store.writeList(
      _signalsKey,
      <BodyDoubleSignal>[...signals, signal]
          .map((signal) => signal.toJson())
          .toList(),
    );
  }

  Future<List<BodyDoubleSignal>> loadSignals() async {
    final rows = await _store.readList(_signalsKey);
    return rows.map(BodyDoubleSignal.fromJson).toList();
  }
}
