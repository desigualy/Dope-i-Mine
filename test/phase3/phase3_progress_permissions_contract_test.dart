import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 3 progress visibility and permissions contract', () {
    test('caregiver operational screens remain routed', () {
      final router = _read('lib/app/router.dart');

      for (final route in <String>[
        '/caregiver/assign-task',
        '/caregiver/assign-routine',
        '/caregiver/permissions/:rid',
        '/caregiver/insights/:rid',
        '/caregiver/assigned-routines',
      ]) {
        expect(router, contains("path: '$route'"), reason: '$route should be routed');
      }
    });

    test('caregiver screens for operations and oversight exist', () {
      for (final path in <String>[
        'lib/presentation/caregiver/caregiver_assign_task_screen.dart',
        'lib/presentation/caregiver/caregiver_assign_routine_screen.dart',
        'lib/presentation/caregiver/caregiver_permissions_screen.dart',
        'lib/presentation/caregiver/caregiver_progress_insights_screen.dart',
        'lib/presentation/caregiver/caregiver_assigned_routines_screen.dart',
      ]) {
        expect(File(path).existsSync(), isTrue, reason: '$path should exist');
      }
    });

    test('caregiver repository exposes progress and permission boundaries', () {
      final repository = _read('lib/data/repositories/caregiver_repository.dart');

      for (final symbol in <String>[
        'CaregiverPermissions',
        'loadPermissions',
        'updatePermissions',
        'loadAlerts',
        'loadBodyDoubleSummaries',
        'exportProgressReport',
        'visibilityLevel',
      ]) {
        expect(repository, contains(symbol), reason: '$symbol should remain exposed');
      }
    });
  });
}

String _read(String path) => File(path).readAsStringSync();
