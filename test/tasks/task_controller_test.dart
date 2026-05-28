import 'package:dope_i_mine/data/repositories/task_repository_impl.dart';
import 'package:dope_i_mine/domain/sidequests/side_quest_model.dart';
import 'package:dope_i_mine/domain/tasks/task_model.dart';
import 'package:dope_i_mine/domain/tasks/task_state_snapshot.dart';
import 'package:dope_i_mine/domain/tasks/task_step_model.dart';
import 'package:dope_i_mine/presentation/tasks/task_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaskController breakdown state', () {
    test('replaceStepWithSubsteps keeps generated micro tasks as children', () {
      final controller = TaskController(_FakeTaskRepository());
      final parent = _step(id: 'parent', text: 'Clean the desk');
      final microTasks = <TaskStepModel>[
        _step(
          id: 'micro-1',
          text: 'Move one cup',
          parentStepId: parent.id,
          depthLevel: 1,
        ),
        _step(
          id: 'micro-2',
          text: 'Throw one wrapper away',
          parentStepId: parent.id,
          depthLevel: 1,
          sequenceNo: 2,
        ),
      ];

      controller.replaceSteps(<TaskStepModel>[parent]);
      controller.replaceStepWithSubsteps(
        stepId: parent.id,
        substeps: microTasks,
        isMinimumVersion: false,
      );

      final children = controller.state.steps
          .where((step) => step.parentStepId == parent.id)
          .toList();
      expect(children, hasLength(2));
      expect(children.map((step) => step.text), contains('Move one cup'));
    });

    test('updateStepCompletion marks a micro task as completed', () {
      final controller = TaskController(_FakeTaskRepository());
      final parent = _step(id: 'parent', text: 'Clean the desk');
      final microTask = _step(
        id: 'micro-1',
        text: 'Move one cup',
        parentStepId: parent.id,
        depthLevel: 1,
      );

      controller.replaceSteps(<TaskStepModel>[parent, microTask]);
      controller.updateStepCompletion(microTask.id, 'completed');

      expect(
        controller.state.steps
            .firstWhere((step) => step.id == microTask.id)
            .status,
        StepStatus.completed,
      );
    });

    test('sideQuestsEnabled false prevents unlocks on step completion', () async {
      final controller = TaskController(
        _FakeTaskRepository(
          sideQuests: const <SideQuestModel>[
            SideQuestModel(
              id: 'quest-1',
              title: 'Bonus action',
              questType: 'bonus',
              rewardXp: 10,
              status: 'available',
              taskId: 'task-1',
            ),
          ],
        ),
      );

      await controller.createTask(
        userId: 'user-a',
        sourceText: 'Clean desk',
        snapshot: _snapshot,
        sideQuestsEnabled: false,
      );
      controller.replaceSteps(<TaskStepModel>[
        _step(id: 'step-1', text: 'One'),
        _step(id: 'step-2', text: 'Two', sequenceNo: 2),
      ]);

      controller.updateStepCompletion('step-1', 'completed');
      controller.updateStepCompletion('step-2', 'completed');

      expect(controller.state.sideQuestsEnabled, isFalse);
      expect(controller.state.showSideQuests, isFalse);
      expect(controller.state.sideQuests, isEmpty);
    });

    test('sideQuestsEnabled true keeps generated quests lockable/unlockable', () async {
      final controller = TaskController(
        _FakeTaskRepository(
          sideQuests: const <SideQuestModel>[
            SideQuestModel(
              id: 'quest-1',
              title: 'Bonus action',
              questType: 'bonus',
              rewardXp: 10,
              status: 'available',
              taskId: 'task-1',
            ),
          ],
        ),
      );

      await controller.createTask(
        userId: 'user-a',
        sourceText: 'Clean desk',
        snapshot: _snapshot,
        sideQuestsEnabled: true,
      );

      expect(controller.state.sideQuests, hasLength(1));
      expect(controller.state.sideQuests.single.status, 'locked');
    });
  });
}

const _snapshot = TaskStateSnapshot(
  mode: SupportMode.audhd,
  energyLevel: EnergyLevel.medium,
  stressLevel: StressLevel.friction,
  timeAvailable: TimeAvailable.fifteenMinutes,
);

TaskStepModel _step({
  required String id,
  required String text,
  String? parentStepId,
  int depthLevel = 0,
  int sequenceNo = 1,
}) {
  return TaskStepModel(
    id: id,
    taskId: 'task-1',
    text: text,
    sequenceNo: sequenceNo,
    depthLevel: depthLevel,
    parentStepId: parentStepId,
  );
}

class _FakeTaskRepository implements TaskRepositoryImpl {
  _FakeTaskRepository({this.sideQuests = const <SideQuestModel>[]});

  final List<SideQuestModel> sideQuests;

  @override
  Future<({
    TaskModel task,
    List<TaskStepModel> steps,
    List<TaskStepModel> minimumVersion,
    List<SideQuestModel> sideQuests,
  })> createTask({
    required String userId,
    required String sourceText,
    required TaskStateSnapshot snapshot,
    required bool sideQuestsEnabled,
  }) async {
    return (
      task: const TaskModel(
        id: 'task-1',
        normalizedTitle: 'Clean desk',
        effortBand: 'low',
        estimatedMinutes: 10,
      ),
      steps: const <TaskStepModel>[],
      minimumVersion: const <TaskStepModel>[],
      sideQuests: sideQuestsEnabled ? sideQuests : const <SideQuestModel>[],
    );
  }

  @override
  Future<List<TaskStepModel>> breakDownStep({
    required String stepId,
    required TaskStateSnapshot snapshot,
    required String stepText,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> completeStep({
    required String userId,
    required String stepId,
  }) {
    throw UnimplementedError();
  }
}