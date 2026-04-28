import 'package:flutter_test/flutter_test.dart';
import 'package:dope_i_mine/data/repositories/task_repository_impl.dart';
import 'package:dope_i_mine/domain/tasks/task_state_snapshot.dart';

void main() {
  group('TaskRepositoryImpl fallback', () {
    test('localTaskFallback returns multiple primary steps for long task text',
        () {
      final result = localTaskFallback(
        'Buy groceries, clean the kitchen, and pack lunch for tomorrow.',
        const TaskStateSnapshot(
          mode: SupportMode.audhd,
          energyLevel: EnergyLevel.medium,
          stressLevel: StressLevel.friction,
          timeAvailable: TimeAvailable.fifteenMinutes,
        ),
      );

      expect(result['primarySteps'], isA<List<dynamic>>());
      expect((result['primarySteps'] as List).length, greaterThan(1));
      expect(result['minimumVersionSteps'], isA<List<dynamic>>());
      expect((result['minimumVersionSteps'] as List).length, equals(1));
    });

    test(
        'localTaskFallback creates actionable steps for a short washing-away task',
        () {
      final result = localTaskFallback(
        'Put the washing away',
        const TaskStateSnapshot(
          mode: SupportMode.audhd,
          energyLevel: EnergyLevel.medium,
          stressLevel: StressLevel.friction,
          timeAvailable: TimeAvailable.fifteenMinutes,
        ),
      );

      final primary = (result['primarySteps'] as List<dynamic>)
          .map((step) => step['text'] as String)
          .toList();

      expect(primary.length, greaterThan(2));
      expect(primary, isNot(contains('Put the washing away')));
      expect(primary, isNot(contains('Mark task as complete when finished')));
    });

    test('localBreakdownFallback splits a long step into multiple substeps',
        () {
      final result = localBreakdownFallback(
        'Prepare slides and send meeting invite to stakeholders.',
      );

      expect(result['substeps'], isA<List<dynamic>>());
      expect((result['substeps'] as List).length, greaterThan(1));
    });

    test('localBreakdownFallback creates actionable laundry put-away substeps',
        () {
      final result = localBreakdownFallback('Fold and put away clean laundry');

      final substeps = (result['substeps'] as List<dynamic>)
          .map((step) => step['text'] as String)
          .toList();

      expect(substeps.length, greaterThan(2));
      expect(substeps.first, isNot('Fold and put away clean laundry'));
    });
  });
}
