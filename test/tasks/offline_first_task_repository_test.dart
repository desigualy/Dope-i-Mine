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
        sideQuestsEnabled: true,
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

  test('offline fallback creates side quests when enabled', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final repository = _repository(preferences);

    final created = await repository.createTask(
      userId: 'user-a',
      sourceText: 'Clean my desk',
      snapshot: _snapshot,
      sideQuestsEnabled: true,
    );

    expect(created.sideQuests, isNotEmpty);
    expect(created.sideQuests, everyElement(hasTaskId(created.task.id)));
  });

  test('offline fallback creates no side quests when disabled', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final repository = _repository(preferences);

    final created = await repository.createTask(
      userId: 'user-a',
      sourceText: 'Clean my desk',
      snapshot: _snapshot,
      sideQuestsEnabled: false,
    );

    expect(created.sideQuests, isEmpty);

    final stored = await repository.localTaskStore.getTaskBundle(created.task.id);
    expect(stored?.sideQuests, isEmpty);
  });

  test('queued offline create task payload includes sideQuestsEnabled', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final syncQueue = SyncQueueService(preferences: preferences);
    final repository = _repository(preferences, syncQueue: syncQueue);

    await repository.createTask(
      userId: 'user-a',
      sourceText: 'Clean my desk',
      snapshot: _snapshot,
      sideQuestsEnabled: false,
    );

    final queue = await syncQueue.loadQueue();
    final createTaskItem = queue.singleWhere((item) => item.type == 'create_task');
    expect(createTaskItem.payload['sideQuestsEnabled'], isFalse);
  });
}

OfflineFirstTaskRepository _repository(
  SharedPreferences preferences, {
  SyncQueueService? syncQueue,
}) {
  return OfflineFirstTaskRepository(
    localTaskStore: LocalTaskStore(
      store: LocalJsonStore('offline.first.task.test', preferences: preferences),
    ),
    localRewardStore: LocalRewardStore(
      store: LocalJsonStore(
        'offline.first.reward.test',
        preferences: preferences,
      ),
    ),
    syncQueue: syncQueue ?? SyncQueueService(preferences: preferences),
    connectivityController: _OfflineConnectivityController(),
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
