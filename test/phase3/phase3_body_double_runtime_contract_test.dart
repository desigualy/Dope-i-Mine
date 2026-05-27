import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 3 body double runtime contract', () {
    test('body double screens and routes remain wired', () {
      _expectFileExists(
          'lib/presentation/body_double/body_double_start_screen.dart');
      _expectFileExists(
        'lib/presentation/body_double/body_double_session_router_screen.dart',
      );
      _expectFileExists(
          'lib/presentation/body_double/body_double_summary_screen.dart');
      _expectFileExists(
        'lib/presentation/body_double/random_body_double_settings_screen.dart',
      );
      _expectFileExists(
        'lib/presentation/body_double/body_double_moderation_screen.dart',
      );

      final router = _read('lib/app/router.dart');
      expect(router, contains("path: '/body-double/start'"));
      expect(router, contains("path: '/body-double/session'"));
      expect(router, contains("path: '/body-double/summary'"));
      expect(router, contains("path: '/body-double/random-settings'"));
      expect(router, contains("path: '/body-double/moderation'"));
    });

    test('body double domain and repository surfaces exist', () {
      _expectFileExists('lib/domain/body_double/body_double_session.dart');
      _expectFileExists(
          'lib/presentation/body_double/body_double_controller.dart');

      final providerText = _read('lib/providers.dart');
      expect(providerText, contains('bodyDouble'));
    });

    test('Phase 3C start screen exposes Dope-i and known-person only', () {
      final startScreen = _read(
        'lib/presentation/body_double/body_double_start_screen.dart',
      );

      expect(startScreen, contains('start-dopei-body-double-button'));
      expect(startScreen, contains('Body double with someone I know'));
      expect(startScreen, contains('Select Partner'));
      expect(startScreen, contains('Privacy Level'));
      expect(startScreen, contains('Send Co-working Invitation'));
      expect(startScreen, isNot(contains('enter-random-queue-button')));
      expect(startScreen, isNot(contains('friend-body-double-user-id-field')));
      expect(startScreen, isNot(contains('Find a partner')));
      expect(startScreen, contains('The session starts only if they accept.'));
      expect(startScreen,
          contains('You are always in control and can leave at any time.'));
    });

    test('Phase 3C known-person flow preserves consent and privacy contract',
        () {
      final controller = _read(
        'lib/presentation/body_double/body_double_controller.dart',
      );
      final session = _read(
        'lib/presentation/body_double/friend_body_double_session_screen.dart',
      );

      expect(controller, contains('allowedReceiverIds'));
      expect(controller, contains('BodyDoubleStatus.waiting'));
      expect(controller, contains('BodyDoubleInviteStatus.pending'));
      expect(controller, contains('Consent confirmed'));
      expect(controller, contains('Invite not sent'));
      expect(session, contains('Known-person body double'));
      expect(session, contains('Preset signals'));
      expect(session, contains('Leave Session'));
    });

    test('Phase 3D/3E random safety gate and runtime remain wired', () {
      final settings = _read(
        'lib/presentation/body_double/random_body_double_settings_screen.dart',
      );
      final controller = _read(
        'lib/presentation/body_double/body_double_controller.dart',
      );
      final session = _read(
        'lib/presentation/body_double/friend_body_double_session_screen.dart',
      );
      final migration = _read(
        'supabase/migrations/202605200001_phase3d3e_random_safety_runtime_hardening.sql',
      );

      expect(settings, contains('enter-random-queue-button'));
      expect(settings, contains('cancel-random-queue-button'));
      expect(settings, contains('Safety gate runs before queue entry'));
      expect(settings, contains('Do not share real names'));
      expect(controller, contains('loadMatchedRandomSession'));
      expect(controller, contains('find_body_double_match'));
      expect(session, contains('Random body double'));
      expect(session, contains('Report Participant'));
      expect(session, contains('Limited random text'));
      expect(session, contains('anonymousOnly'));
      expect(migration, contains('body_double_queue_minor_safety_check'));
      expect(migration, contains('random_suspended'));
      expect(migration, contains('user_blocks'));
      expect(migration, contains('random_match_created'));
      expect(
          migration,
          contains(
              "p_communication_mode not in ('quiet', 'presetSignals', 'textOnly')"));
      expect(migration, contains('voice_requested_but_disabled'));
      expect(migration, contains('q.user_id <> v_my_entry.user_id'));
    });

    test('random body-double domain enforces queue compatibility locally', () {
      final domain = _read('lib/domain/body_double/body_double_session.dart');

      expect(domain, contains('userId == other.userId'));
      expect(domain, contains('BodyDoubleStatus.waiting'));
      expect(domain, contains('expiresAt.isAfter(DateTime.now())'));
      expect(domain,
          contains('sessionLengthMinutes == other.sessionLengthMinutes'));
      expect(domain, contains("json['sessionType'] ?? json['session_type']"));
      expect(domain, contains('snapchat'));
      expect(domain, contains('post code'));
    });
  });
}

String _read(String path) => File(path).readAsStringSync();

void _expectFileExists(String path) {
  expect(File(path).existsSync(), isTrue, reason: '$path should exist');
}
