import 'package:dope_i_mine/domain/tasks/task_state_snapshot.dart';
import 'package:dope_i_mine/domain/tasks/task_model.dart';
import 'package:dope_i_mine/domain/tasks/task_step_model.dart';
import 'package:dope_i_mine/presentation/tasks/task_breakdown_screen.dart';
import 'package:dope_i_mine/presentation/tasks/task_controller.dart';
import 'package:dope_i_mine/presentation/rewards/reward_controller.dart';
import 'package:dope_i_mine/data/repositories/reward_repository_impl.dart';
import 'package:dope_i_mine/domain/rewards/user_stats.dart';
import 'package:dope_i_mine/data/repositories/auth_repository_impl.dart';
import 'package:dope_i_mine/domain/auth/auth_user.dart';
import 'package:dope_i_mine/providers.dart';
import 'package:dope_i_mine/presentation/sidequests/side_quest_controller.dart';
import 'package:dope_i_mine/data/repositories/side_quest_repository_impl.dart';
import 'package:dope_i_mine/domain/sidequests/side_quest_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Break down more uses the original TaskStateSnapshot from task creation',
    (tester) async {
      final repo = _SnapshotCapturingTaskRepository();
      final snapshot = TaskStateSnapshot(
        mode: SupportMode.burnout,
        energyLevel: EnergyLevel.low,
        stressLevel: StressLevel.shutdown,
        timeAvailable: TimeAvailable.twoMinutes,
      );

      final container = ProviderContainer(
        overrides: <Override>[
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          // TaskBreakdownScreen watches rewardControllerProvider which depends on
          // rewardRepositoryProvider -> Supabase. Override it to keep the test
          // hermetic.
          rewardControllerProvider
              .overrideWith((ref) => _FakeRewardController()),
          // SideQuestPanel depends on sideQuestRepositoryProvider -> Supabase.
          // Our test uses TaskBreakdownScreen which conditionally renders
          // SideQuestPanel, so override it to keep the widget tree buildable.
          sideQuestControllerProvider.overrideWith(
              (ref) => SideQuestController(_FakeSideQuestRepository())),
          sideQuestRepositoryProvider
              .overrideWithValue(_FakeSideQuestRepository()),
          taskRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      // Seed controller state as if a task had just been created with a snapshot.
      // NOTE: We avoid calling TaskController.createTask() here because it depends
      // on a repository result containing a TaskModel.
      container.read(taskControllerProvider.notifier).state = TaskViewState(
        loading: false,
        task: const TaskModel(
          id: 'task-1',
          normalizedTitle: 'Clean the desk',
          effortBand: 'low',
          estimatedMinutes: 2,
        ),
        steps: const <TaskStepModel>[
          TaskStepModel(
            id: 'step-1',
            taskId: 'task-1',
            text: 'Clean the desk',
            sequenceNo: 1,
            depthLevel: 0,
          ),
        ],
        snapshot: snapshot,
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: TaskBreakdownScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger a breakdown (the icon is present on section cards).
      await tester.tap(find.byIcon(Icons.auto_fix_high).first);
      await tester.pumpAndSettle();

      expect(repo.lastBreakdownSnapshot, isNotNull);
      expect(repo.lastBreakdownSnapshot!.mode, SupportMode.burnout);
      expect(repo.lastBreakdownSnapshot!.energyLevel, EnergyLevel.low);
      expect(repo.lastBreakdownSnapshot!.stressLevel, StressLevel.shutdown);
      expect(
          repo.lastBreakdownSnapshot!.timeAvailable, TimeAvailable.twoMinutes);
    },
  );
}

class _SnapshotCapturingTaskRepository {
  TaskStateSnapshot? lastBreakdownSnapshot;

  Future<
      ({
        dynamic task,
        List<TaskStepModel> steps,
        List<TaskStepModel> minimumVersion,
        List<dynamic> sideQuests,
      })> createTask({
    required String userId,
    required String sourceText,
    required TaskStateSnapshot snapshot,
  }) async {
    return (
      task: null,
      steps: const <TaskStepModel>[],
      minimumVersion: const <TaskStepModel>[],
      sideQuests: const <dynamic>[],
    );
  }

  Future<List<TaskStepModel>> breakDownStep({
    required String stepId,
    required TaskStateSnapshot snapshot,
    required String stepText,
  }) async {
    lastBreakdownSnapshot = snapshot;
    return const <TaskStepModel>[
      TaskStepModel(
        id: 'sub-1',
        taskId: 'task-1',
        parentStepId: 'step-1',
        text: 'Do one small thing',
        sequenceNo: 1,
        depthLevel: 1,
      ),
    ];
  }

  Future<void> completeStep(
      {required String userId, required String stepId}) async {}
}

class _FakeRewardController extends RewardController {
  _FakeRewardController() : super(_FakeRewardRepository());
}

class _FakeRewardRepository implements RewardRepositoryImpl {
  @override
  Future<UserStats> getUserStats(String userId) async {
    return const UserStats(
      totalXp: 0,
      level: 1,
      currentStreak: 0,
      xpToNextLevel: 1000,
      progressToNextLevel: 0,
    );
  }

  @override
  Future<void> awardXp({
    required String userId,
    required int amount,
    required String key,
    String? sourceType,
    String? sourceId,
  }) async {
    // no-op
  }
}

class _FakeAuthRepository implements AuthRepositoryImpl {
  @override
  AuthUser? getCurrentUser() {
    // Provide a stable user id so TaskBreakdownScreen post-frame reward refresh
    // logic does not crash.
    return const AuthUser(id: 'user-1', email: 'user-1@example.com');
  }

  @override
  Future<void> completeForcedPasswordChange(String password) async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<AuthUser?> signIn(
      {required String email, required String password}) async {
    return const AuthUser(id: 'user-1', email: 'user-1@example.com');
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthUser?> signUp({
    required String email,
    required String password,
    String accountType = 'user',
  }) async {
    return const AuthUser(id: 'user-1', email: 'user-1@example.com');
  }

  @override
  Future<void> updatePassword(String password) async {}
}

class _FakeSideQuestRepository implements SideQuestRepositoryImpl {
  @override
  Future<void> accept(String sideQuestId) async {}

  @override
  Future<void> complete(
      {required String userId, required String sideQuestId}) async {}

  @override
  Future<void> dismiss(String sideQuestId) async {}

  @override
  Future<List<SideQuestModel>> getAvailableForTask(
      String userId, String taskId) async {
    return const <SideQuestModel>[];
  }
}
