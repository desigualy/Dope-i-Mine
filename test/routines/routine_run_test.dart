
import 'package:flutter_test/flutter_test.dart';
import 'package:dope_i_mine/presentation/routines/routine_run_controller.dart';
import 'package:dope_i_mine/domain/routines/routine_step_model.dart';

void main() {
  test('routine runner advances and tracks completed steps', () {
    final controller = RoutineRunController();
    controller.start(const <RoutineStepModel>[
      RoutineStepModel(
        id: '1',
        routineId: 'r1',
        stepText: 'First',
        sequenceNo: 1,
        depthLevel: 0,
      ),
      RoutineStepModel(
        id: '2',
        routineId: 'r1',
        stepText: 'Second',
        sequenceNo: 2,
        depthLevel: 0,
      ),
    ]);

    expect(controller.state.currentIndex, 0);
    expect(controller.state.completedStepIds.isEmpty, true);

    controller.completeCurrent();

    expect(controller.state.completedStepIds.contains('1'), true);
    expect(controller.state.currentIndex, 1);
  });
}
