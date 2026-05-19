import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 3 caregiver operations contract', () {
    test('temporary password schema migration is committed', () {
      final migration = _read(
        'supabase/migrations/202605150004_caregiver_temporary_password_gate.sql',
      );

      expect(migration, contains('must_change_password'));
      expect(migration, contains('temporary_password_created_at'));
      expect(migration, contains('temporary_password_set_at'));
      expect(migration, contains('requires_password_setup'));
      expect(migration, contains('password_setup_sent_at'));
      expect(migration, contains('pg_notify'));
    });

    test('caregiver invite function owns temporary password bootstrap', () {
      final function = _read('supabase/functions/send-caregiver-invite/index.ts');

      expect(function, contains('temporaryPassword'));
      expect(function, contains('must_change_password'));
      expect(function, contains('temporary_password_created_at'));
      expect(function, contains('temporary_password_set_at'));
      expect(function, contains("status: 'accepted'"));
      expect(function, isNot(contains('console.log(temporaryPassword')));
    });

    test('forced password change is route-gated before caregiver dashboard', () {
      final postAuthRoute = _read('lib/app/post_auth_route.dart');
      final router = _read('lib/app/router.dart');

      expect(postAuthRoute, contains('mustChangePassword'));
      expect(postAuthRoute, contains("return '/force-password-change'"));
      expect(router, contains("path: '/force-password-change'"));
      expect(router, contains('ForcePasswordChangeScreen'));
    });

    test('caregiver operations surface remains available', () {
      final repository = _read('lib/data/repositories/caregiver_repository.dart');

      for (final symbol in <String>[
        'createEmailInvite',
        'cancelEmailInvite',
        'revokeRelationship',
        'assignTask',
        'assignRoutine',
        'loadAssignedTasks',
        'loadAssignedRoutines',
        'loadPermissions',
        'updatePermissions',
        'sendNudge',
        'exportProgressReport',
      ]) {
        expect(repository, contains(symbol), reason: '$symbol should remain exposed');
      }
    });
  });
}

String _read(String path) => File(path).readAsStringSync();
