import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/caregiver_repository.dart';
import '../../data/repositories/caregiver_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/caregiver/caregiver_models.dart';
import '../../domain/notifications/app_notification.dart';
import '../../providers.dart';

class CaregiverState {
  const CaregiverState({
    this.relationships = const [],
    this.emailInvites = const [],
    this.assignedTasks = const [],
    this.assignedRoutines = const [],
    this.isLoading = false,
    this.error,
  });

  final List<CaregiverRelationship> relationships;
  final List<CaregiverEmailInvite> emailInvites;
  final List<CaregiverAssignedTask> assignedTasks;
  final List<CaregiverAssignedRoutine> assignedRoutines;
  final bool isLoading;
  final String? error;

  CaregiverState copyWith({
    List<CaregiverRelationship>? relationships,
    List<CaregiverEmailInvite>? emailInvites,
    List<CaregiverAssignedTask>? assignedTasks,
    List<CaregiverAssignedRoutine>? assignedRoutines,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CaregiverState(
      relationships: relationships ?? this.relationships,
      emailInvites: emailInvites ?? this.emailInvites,
      assignedTasks: assignedTasks ?? this.assignedTasks,
      assignedRoutines: assignedRoutines ?? this.assignedRoutines,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

final caregiverRepositoryProvider = Provider<CaregiverRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  if (client == null) throw StateError('Supabase client is required');
  return CaregiverRepositoryImpl(
    client: client,
    userId: client.auth.currentUser?.id,
  );
});

final caregiverControllerProvider =
    StateNotifierProvider<CaregiverController, CaregiverState>((ref) {
  return CaregiverController(
    ref.watch(caregiverRepositoryProvider),
    ref.watch(notificationRepositoryProvider),
  );
});

class CaregiverController extends StateNotifier<CaregiverState> {
  CaregiverController(this._repository, this._notifications)
      : super(const CaregiverState()) {
    refresh();
  }

  final CaregiverRepository _repository;
  final NotificationRepositoryImpl _notifications;

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final relationships = await _repository.loadRelationships();
    final emailInvites = await _repository.loadEmailInvites();
    final tasks = await _repository.loadAssignedTasks();
    final routines = await _repository.loadAssignedRoutines();
    state = state.copyWith(
      relationships: relationships,
      emailInvites: emailInvites,
      assignedTasks: tasks,
      assignedRoutines: routines,
      isLoading: false,
    );
  }

  Future<bool> sendRequest(
    String email,
    CaregiverRole role, {
    required String temporaryPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.createEmailInvite(
      targetUserEmail: email,
      role: role,
      temporaryPassword: temporaryPassword,
    );
    if (result == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Could not create or send caregiver invite.',
      );
      return false;
    }

    await refresh();
    return true;
  }

  Future<void> cancelPendingInvite(String inviteId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _repository.cancelEmailInvite(inviteId);
    await refresh();
  }

  Future<bool> acceptEmailInvite(String inviteId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.acceptEmailInvite(inviteId);
    if (result == null) {
      state = state.copyWith(
        isLoading: false,
        error:
            'Could not accept caregiver invite. It may be expired or for a different email.',
      );
      return false;
    }
    await refresh();
    return true;
  }

  Future<void> respondToRequest(String relationshipId, bool accept) async {
    await _repository.respondToRelationshipRequest(
      relationshipId: relationshipId,
      accept: accept,
    );
    await refresh();
  }

  Future<void> revokeRelationship(String relationshipId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _repository.revokeRelationship(relationshipId);
    await refresh();
  }

  Future<void> assignTask(
    String targetUserId,
    String title, {
    String? description,
    List<String>? steps,
    DateTime? due,
  }) async {
    final taskId = await _repository.assignTask(
      targetUserId: targetUserId,
      taskTitle: title,
      taskDescription: description,
      steps: steps,
      dueAt: due,
    );
    if (taskId != null) {
      await _notifications.createNotification(
        userId: targetUserId,
        type: AppNotificationType.caregiverTaskAssigned,
        title: 'New caregiver task',
        body: 'A caregiver assigned you a task: $title.',
        route: '/tasks/summary',
        routeParams: <String, dynamic>{'source': 'caregiver'},
        sourceType: 'caregiver_task',
        sourceId: taskId,
      );
    }
    await refresh();
  }

  Future<void> respondToTask(String taskId, CaregiverTaskStatus status) async {
    await _repository.respondToAssignedTask(
      assignedTaskId: taskId,
      status: status,
    );
    await refresh();
  }

  Future<void> assignRoutine(
    String targetUserId, {
    String? routineId,
    required String routineTitle,
    String schedule = 'Flexible',
  }) async {
    final succeeded = await _repository.assignRoutine(
      targetUserId: targetUserId,
      routineId: routineId,
      routineTitle: routineTitle,
      schedule: schedule,
    );
    if (succeeded) {
      await _notifications.createNotification(
        userId: targetUserId,
        type: AppNotificationType.caregiverRoutineAssigned,
        title: 'New caregiver routine',
        body: 'A caregiver assigned you a routine: $routineTitle.',
        route: '/routines',
        routeParams: <String, dynamic>{'source': 'caregiver'},
        sourceType: 'caregiver_routine',
        sourceId: routineId,
      );
    }
    await refresh();
  }

  Future<void> respondToRoutine(
    String routineAssignmentId,
    CaregiverRoutineStatus status,
  ) async {
    await _repository.respondToAssignedRoutine(
      assignedRoutineId: routineAssignmentId,
      status: status,
    );
    await refresh();
  }

  Future<void> suggestSideQuest(String targetUserId, String title) async {
    await _repository.suggestSideQuest(
      targetUserId: targetUserId,
      title: title,
    );
    await _notifications.createNotification(
      userId: targetUserId,
      type: AppNotificationType.sideQuestSuggested,
      title: 'Side quest suggestion',
      body: 'A caregiver suggested a side quest: $title.',
      route: '/tasks/summary',
      routeParams: <String, dynamic>{'source': 'caregiver'},
      sourceType: 'side_quest',
      sourceId: null,
    );
    await refresh();
  }

  Future<void> sendNudge(
    String relId,
    String targetUserId,
    String msg, {
    CaregiverNudgeTone tone = CaregiverNudgeTone.gentle,
  }) async {
    await _repository.sendNudge(
      relationshipId: relId,
      targetUserId: targetUserId,
      message: msg,
      tone: tone,
    );
    await _notifications.createNotification(
      userId: targetUserId,
      type: AppNotificationType.caregiverNudge,
      title: 'Caregiver nudge',
      body: msg,
      route: '/tasks/summary',
      routeParams: <String, dynamic>{'source': 'caregiver'},
      sourceType: 'caregiver_nudge',
      sourceId: relId,
    );
    await refresh();
  }

  Future<void> setMinorRandomApproval(
      String targetUserId, bool approved) async {
    await _repository.setMinorRandomApproval(
      targetUserId: targetUserId,
      approved: approved,
    );
    await refresh();
  }

  Future<void> inviteToBodyDouble(String targetUserId, String category) async {
    await _repository.inviteToBodyDouble(
      targetUserId: targetUserId,
      taskCategory: category,
    );
    await _notifications.createNotification(
      userId: targetUserId,
      type: AppNotificationType.bodyDoubleInvite,
      title: 'Body double invite',
      body: 'A caregiver invited you to a body double session.',
      route: '/body-double/session',
      routeParams: <String, dynamic>{'source': 'caregiver'},
      sourceType: 'body_double_invite',
      sourceId: null,
    );
    await refresh();
  }
}
