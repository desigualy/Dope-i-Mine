import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/caregiver_repository.dart';
import '../../data/repositories/caregiver_repository_impl.dart';
import '../../domain/caregiver/caregiver_models.dart';
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
  }) {
    return CaregiverState(
      relationships: relationships ?? this.relationships,
      emailInvites: emailInvites ?? this.emailInvites,
      assignedTasks: assignedTasks ?? this.assignedTasks,
      assignedRoutines: assignedRoutines ?? this.assignedRoutines,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
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
  return CaregiverController(ref.watch(caregiverRepositoryProvider));
});

class CaregiverController extends StateNotifier<CaregiverState> {
  CaregiverController(this._repository) : super(const CaregiverState()) {
    refresh();
  }

  final CaregiverRepository _repository;

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
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

  Future<void> sendRequest(String email, CaregiverRole role) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.createEmailInvite(
      targetUserEmail: email,
      role: role,
    );
    if (result == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Could not create or send caregiver invite.',
      );
    } else {
      await refresh();
    }
  }

  Future<bool> acceptEmailInvite(String inviteId) async {
    state = state.copyWith(isLoading: true);
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
    await _repository.revokeRelationship(relationshipId);
    await refresh();
  }

  Future<void> assignTask(
    String targetUserId,
    String title, {
    List<String>? steps,
    DateTime? due,
  }) async {
    await _repository.assignTask(
      targetUserId: targetUserId,
      taskTitle: title,
      steps: steps,
      dueAt: due,
    );
    await refresh();
  }

  Future<void> respondToTask(String taskId, CaregiverTaskStatus status) async {
    await _repository.respondToAssignedTask(
      assignedTaskId: taskId,
      status: status,
    );
    await refresh();
  }

  Future<void> assignRoutine(String targetUserId, String routineId) async {
    await _repository.assignRoutine(
      targetUserId: targetUserId,
      routineId: routineId,
    );
    await refresh();
  }

  Future<void> suggestSideQuest(String targetUserId, String title) async {
    await _repository.suggestSideQuest(
      targetUserId: targetUserId,
      title: title,
    );
    await refresh();
  }

  Future<void> sendNudge(String relId, String targetUserId, String msg) async {
    await _repository.sendNudge(
      relationshipId: relId,
      targetUserId: targetUserId,
      message: msg,
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
    await refresh();
  }
}
