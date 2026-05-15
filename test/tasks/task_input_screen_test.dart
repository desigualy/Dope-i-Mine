import 'package:dope_i_mine/data/repositories/auth_repository_impl.dart';
import 'package:dope_i_mine/domain/auth/auth_user.dart';
import 'package:dope_i_mine/domain/sidequests/side_quest_model.dart';
import 'package:dope_i_mine/domain/tasks/task_model.dart';
import 'package:dope_i_mine/domain/tasks/task_state_snapshot.dart';
import 'package:dope_i_mine/domain/tasks/task_step_model.dart';
import 'package:dope_i_mine/presentation/tasks/task_controller.dart';
import 'package:dope_i_mine/presentation/tasks/task_input_screen.dart';
import 'package:dope_i_mine/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('New task falls back to local user when auth lookup fails',
      (tester) async {
    final repository = _FakeTaskRepository();
    final router = GoRouter(
      initialLocation: '/tasks/new',
      routes: <RouteBase>[
        GoRoute(
          path: '/tasks/new',
          builder: (_, __) => const TaskInputScreen(),
        ),
        GoRoute(
          path: '/tasks/breakdown',
          builder: (_, __) => const _TaskBreakdownProbe(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          authRepositoryProvider.overrideWithValue(_ThrowingAuthRepository()),
          taskRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'What do you need to do?'),
      'Clean my desk',
    );
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Break task down'));
    await tester.pumpAndSettle();

    expect(repository.lastUserId, 'local_user');
    expect(find.textContaining('Today’s Task: Clean my desk'), findsOneWidget);
    expect(find.textContaining('Look at one small area'), findsOneWidget);
  });
}

class _TaskBreakdownProbe extends ConsumerWidget {
  const _TaskBreakdownProbe();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskControllerProvider);
    return Material(
      child: Column(
        children: <Widget>[
          Text('Today’s Task: ${taskState.task?.normalizedTitle ?? ''}'),
          ...taskState.steps.map((step) => Text(step.text)),
        ],
      ),
    );
  }
}

class _ThrowingAuthRepository implements AuthRepositoryImpl {
  @override
  AuthUser? getCurrentUser() => throw StateError('Supabase unavailable');

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<AuthUser?> signIn({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthUser?> signUp({
    required String email,
    required String password,
    String accountType = 'user',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> updatePassword(String password) async {}
}

class _FakeTaskRepository {
  String? lastUserId;

  Future<({
    TaskModel task,
    List<TaskStepModel> steps,
    List<TaskStepModel> minimumVersion,
    List<SideQuestModel> sideQuests,
  })> createTask({
    required String userId,
    required String sourceText,
    required TaskStateSnapshot snapshot,
  }) async {
    lastUserId = userId;
    return (
      task: TaskModel(
        id: 'task-1',
        normalizedTitle: sourceText,
        effortBand: 'low',
        estimatedMinutes: 10,
      ),
      steps: const <TaskStepModel>[
        TaskStepModel(
          id: 'step-1',
          taskId: 'task-1',
          text: 'Look at one small area',
          sequenceNo: 1,
          depthLevel: 0,
        ),
      ],
      minimumVersion: const <TaskStepModel>[
        TaskStepModel(
          id: 'min-1',
          taskId: 'task-1',
          text: 'Touch one item',
          sequenceNo: 1,
          depthLevel: 0,
          isMinimumPath: true,
        ),
      ],
      sideQuests: const <SideQuestModel>[],
    );
  }

  Future<List<TaskStepModel>> breakDownStep({
    required String stepId,
    required TaskStateSnapshot snapshot,
    required String stepText,
  }) async {
    return const <TaskStepModel>[];
  }

  Future<void> completeStep({required String userId, required String stepId}) async {}
}