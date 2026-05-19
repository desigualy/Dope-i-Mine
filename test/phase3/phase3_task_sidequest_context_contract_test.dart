import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 3 task side quest and breakdown context contract', () {
    test('side quest panel is fully hidden when side quests are toggled off', () {
      final breakdown = _read('lib/presentation/tasks/task_breakdown_screen.dart');

      expect(
        breakdown,
        contains('if (state.task?.id != null && state.showSideQuests)'),
      );
      expect(breakdown, contains('SideQuestPanel(taskId: state.task!.id)'));
    });

    test('follow-up breakdown uses stored TaskStateSnapshot before fallback', () {
      final breakdown = _read('lib/presentation/tasks/task_breakdown_screen.dart');

      expect(breakdown, contains('final state = ref.read(taskControllerProvider);'));
      expect(breakdown, contains('final snapshot = state.snapshot ??'));
      expect(breakdown, contains('snapshot: snapshot'));
      expect(breakdown, contains('stepText: step.text'));
    });

    test('task controller stores original snapshot when task is created', () {
      final controller = _read('lib/presentation/tasks/task_controller.dart');

      expect(controller, contains('TaskViewState(loading: true, snapshot: snapshot)'));
      expect(controller, contains('snapshot: snapshot'));
    });
  });
}

String _read(String path) => File(path).readAsStringSync();
