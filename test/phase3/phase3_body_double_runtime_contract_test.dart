import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 3 body double runtime contract', () {
    test('body double screens and routes remain wired', () {
      _expectFileExists('lib/presentation/body_double/body_double_start_screen.dart');
      _expectFileExists(
        'lib/presentation/body_double/body_double_session_router_screen.dart',
      );
      _expectFileExists('lib/presentation/body_double/body_double_summary_screen.dart');
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
      _expectFileExists('lib/presentation/body_double/body_double_controller.dart');

      final providerText = _read('lib/providers.dart');
      expect(providerText, contains('bodyDouble'));
    });
  });
}

String _read(String path) => File(path).readAsStringSync();

void _expectFileExists(String path) {
  expect(File(path).existsSync(), isTrue, reason: '$path should exist');
}
