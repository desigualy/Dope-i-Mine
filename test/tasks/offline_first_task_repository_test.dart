import 'package:dope_i_mine/core/network/connectivity_controller.dart';
import 'package:dope_i_mine/core/network/connectivity_status.dart';
import 'package:dope_i_mine/core/sync/sync_queue_service.dart';
import 'package:dope_i_mine/data/local/local_json_store.dart';
import 'package:dope_i_mine/data/local/local_reward_store.dart';
import 'package:dope_i_mine/data/local/local_task_store.dart';
import 'package:dope_i_mine/data/repositories/offline_first_task_repository.dart';
import 'package:dope_i_mine/domain/tasks/task_state_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'offline step breakdown keeps generated substeps attached to parent task',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final preferences = await SharedPreferences.getInstance();
      final localTaskStore = LocalTaskStore(
        store:
            LocalJsonStore('offline.first.task.test', preferences: preferences),
      );
      final repository = OfflineFirstTaskRepository(
        localTaskStore: localTaskStore,
        localRewardStore: LocalRewardStore(
          store: LocalJsonStore(
            'offline.first.reward.test',
            preferences: preferences,
          ),
        ),
        syncQueue: SyncQueueService(preferences: preferences),
        connectivityController: _OfflineConnectivityController(),
      );

      final created = await repository.createTask(
        userId: 'user-a',
        sourceText: 'Clean my desk',
        snapshot: _snapshot,
      );
      final parentStep = created.steps.first;

      final generated = await repository.breakDownStep(
        stepId: parentStep.id,
        snapshot: _snapshot,
        stepText: parentStep.text,
      );

      expect(generated, isNotEmpty);
      expect(generated, everyElement(hasTaskId(created.task.id)));
      expect(
        generated,
        isNot(anyElement(hasTaskId('local_unknown_task'))),
      );
      final storedStepIds = (await localTaskStore.loadSteps(created.task.id))
          .map((step) => step.id)
          .toSet();
      expect(storedStepIds, containsAll(generated.map((step) => step.id)));
    },
  );
}

const _snapshot = TaskStateSnapshot(
  mode: SupportMode.audhd,
  energyLevel: EnergyLevel.medium,
  stressLevel: StressLevel.friction,
  timeAvailable: TimeAvailable.fifteenMinutes,
);

Matcher hasTaskId(String taskId) => isA<dynamic>().having(
      (step) => step.taskId,
      'taskId',
      taskId,
    );

class _OfflineConnectivityController extends ConnectivityController {
  _OfflineConnectivityController() : super();

  @override
  Future<ConnectivityStatus> refresh() async => ConnectivityStatus.offline;
}
