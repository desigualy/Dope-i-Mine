import 'package:dope_i_mine/data/repositories/task_repository_impl.dart';
import 'package:dope_i_mine/domain/tasks/task_state_snapshot.dart';

void main() {
  final examples = <String>[
    'put washing away',
    'wash the dishes',
    'reply to emails',
    'clean the kitchen counters and mop the floor',
    'buy groceries',
  ];

  final snapshot = TaskStateSnapshot(
    mode: SupportMode.audhd,
    energyLevel: EnergyLevel.medium,
    stressLevel: StressLevel.friction,
    timeAvailable: TimeAvailable.fifteenMinutes,
  );

  for (final ex in examples) {
    final primary = localTaskFallback(ex, snapshot);
    print('\nInput: $ex');
    print('Normalized title: ${primary['normalizedTitle']}');
    print('Primary steps:');
    for (final s in (primary['primarySteps'] as List)) {
      print(' - ${s['text']}');
    }
    print('Minimum version:');
    for (final s in (primary['minimumVersionSteps'] as List)) {
      print(' - ${s['text']}');
    }
  }
}
