import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/caregiver/caregiver_models.dart';
import '../../domain/body_double/body_double_session.dart';
import 'caregiver_repository.dart';

class CaregiverRepositoryImpl implements CaregiverRepository {
  CaregiverRepositoryImpl({
    required this.client,
    required this.userId,
  });

  final SupabaseClient client;
  final String? userId;

  @override
  Future<List<CaregiverRelationship>> loadRelationships() async {
    if (userId == null) return [];
    try {
      final res = await client.from('caregiver_relationships').select('''
            *,
            caregiver:users_profile!caregiver_relationships_caregiver_user_id_fkey(display_name, email),
            supported:users_profile!caregiver_relationships_supported_user_id_fkey(display_name, email)
          ''').or('caregiver_user_id.eq.$userId,supported_user_id.eq.$userId');

      return (res as List<dynamic>).map((json) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(json);
        data['caregiver_name'] =
            json['caregiver']?['display_name'] ?? json['caregiver']?['email'];
        data['supported_name'] =
            json['supported']?['display_name'] ?? json['supported']?['email'];
        return CaregiverRelationship.fromJson(data);
      }).where((relationship) {
        return relationship.status == CaregiverRelationshipStatus.accepted ||
            relationship.status == CaregiverRelationshipStatus.pending;
      }).toList();
    } catch (e) {
      debugPrint('Caregiver relationships embedded load failed: $e');
      return _loadRelationshipsWithoutEmbeddedProfiles();
    }
  }

  Future<List<CaregiverRelationship>>
      _loadRelationshipsWithoutEmbeddedProfiles() async {
    if (userId == null) return [];
    try {
      final res = await client
          .from('caregiver_relationships')
          .select()
          .or('caregiver_user_id.eq.$userId,supported_user_id.eq.$userId');

      return (res as List<dynamic>)
          .map((json) => CaregiverRelationship.fromJson(json))
          .where((relationship) {
        return relationship.status == CaregiverRelationshipStatus.accepted ||
            relationship.status == CaregiverRelationshipStatus.pending;
      }).toList();
    } catch (e) {
      debugPrint('Caregiver relationships fallback load failed: $e');
      return [];
    }
  }

  @override
  Future<List<CaregiverEmailInvite>> loadEmailInvites() async {
    if (userId == null) return [];
    try {
      final res = await client
          .from('caregiver_email_invites')
          .select()
          .eq('inviter_user_id', userId!)
          .order('created_at', ascending: false);
      return (res as List<dynamic>)
          .map((json) => CaregiverEmailInvite.fromJson(json))
          .where(
              (invite) => invite.status == CaregiverEmailInviteStatus.pending)
          .toList();
    } catch (e) {
      debugPrint('Caregiver email invites load failed: $e');
      return [];
    }
  }

  @override
  Future<void> cancelEmailInvite(String inviteId) async {
    if (userId == null) return;
    final trimmedInviteId = inviteId.trim();
    if (trimmedInviteId.isEmpty) return;

    try {
      await client.rpc(
        'cancel_caregiver_email_invite',
        params: <String, dynamic>{'p_invite_id': trimmedInviteId},
      );
    } catch (_) {
      await client
          .from('caregiver_email_invites')
          .update(<String, dynamic>{'status': 'revoked'})
          .eq('id', trimmedInviteId)
          .eq('inviter_user_id', userId!)
          .eq('status', 'pending');
    }
  }

  @override
  Future<CaregiverEmailInvite?> createEmailInvite({
    required String targetUserEmail,
    required CaregiverRole role,
    required String caregiverPassword,
  }) async {
    if (userId == null) return null;
    final email = targetUserEmail.trim().toLowerCase();
    final password = caregiverPassword.trim();
    if (!email.contains('@') || password.length < 8) return null;
    try {
      final res = await client
          .from('caregiver_email_invites')
          .upsert(
            <String, dynamic>{
              'inviter_user_id': userId,
              'invitee_email': email,
              'role': role.name,
              'status': 'pending',
              'accepted_user_id': null,
              'accepted_at': null,
              'requires_password_setup': false,
              'password_setup_sent_at': null,
              'expires_at': DateTime.now()
                  .add(const Duration(days: 30))
                  .toIso8601String(),
            },
            onConflict: 'inviter_user_id,invitee_email',
          )
          .select()
          .single();

      final inviteSent = await _sendCaregiverInviteEmail(
        inviteId: res['id'] as String,
        targetUserEmail: email,
        role: role,
        caregiverPassword: password,
      );

      if (!inviteSent) return null;

      return CaregiverEmailInvite.fromJson(res);
    } catch (e) {
      debugPrint('Caregiver email invite failed: $e');
      return null;
    }
  }

  @override
  Future<CaregiverRelationship?> createRelationshipRequest({
    required String targetUserEmail,
    required CaregiverRole role,
    String? label,
  }) async {
    if (userId == null) return null;
    try {
      final userRes = await client
          .from('users_profile')
          .select('id')
          .eq('email', targetUserEmail)
          .maybeSingle();

      if (userRes == null) return null;
      final targetId = userRes['id'] as String;

      final res = await client
          .from('caregiver_relationships')
          .insert({
            'caregiver_user_id': userId,
            'supported_user_id': targetId,
            'role': role.name,
            'status': 'pending',
            'relationship_label': label,
          })
          .select()
          .single();

      return CaregiverRelationship.fromJson(res);
    } catch (e) {
      debugPrint('Caregiver relationship request failed: $e');
      return null;
    }
  }

  Future<bool> _sendCaregiverInviteEmail({
    required String inviteId,
    required String targetUserEmail,
    required CaregiverRole role,
    required String caregiverPassword,
  }) async {
    try {
      final response = await client.functions.invoke(
        'send-caregiver-invite',
        body: <String, dynamic>{
          'inviteId': inviteId,
          'targetUserEmail': targetUserEmail,
          'role': role.name,
          'caregiverPassword': caregiverPassword,
        },
      );

      final data = response.data;
      return data is Map && data['ok'] == true;
    } catch (error) {
      debugPrint('Caregiver invite email dispatch failed: $error');
      return false;
    }
  }

  @override
  Future<CaregiverRelationship?> acceptEmailInvite(String inviteId) async {
    if (userId == null) return null;
    final trimmedInviteId = inviteId.trim();
    if (trimmedInviteId.isEmpty) return null;

    try {
      final response = await client.functions.invoke(
        'accept-caregiver-invite',
        body: <String, dynamic>{'inviteId': trimmedInviteId},
      );

      final data = response.data;
      if (data is! Map || data['ok'] != true) return null;

      final relationship = data['relationship'];
      if (relationship is Map) {
        return CaregiverRelationship.fromJson(
          Map<String, dynamic>.from(relationship),
        );
      }

      return null;
    } catch (e) {
      debugPrint('Caregiver email invite accept failed: $e');
      return null;
    }
  }

  @override
  Future<void> respondToRelationshipRequest({
    required String relationshipId,
    required bool accept,
  }) async {
    try {
      await client.from('caregiver_relationships').update({
        'status': accept ? 'accepted' : 'declined',
        'accepted_at': accept ? DateTime.now().toIso8601String() : null,
      }).eq('id', relationshipId);
    } catch (_) {}
  }

  @override
  Future<void> revokeRelationship(String relationshipId) async {
    final trimmedRelationshipId = relationshipId.trim();
    if (trimmedRelationshipId.isEmpty) return;

    try {
      await client.rpc(
        'revoke_caregiver_relationship',
        params: <String, dynamic>{
          'p_relationship_id': trimmedRelationshipId,
        },
      );
    } catch (_) {
      await client.from('caregiver_relationships').update({
        'status': 'revoked',
        'revoked_at': DateTime.now().toIso8601String(),
      }).eq('id', trimmedRelationshipId);
    }
  }

  @override
  Future<CaregiverPermissions?> loadPermissions(String relationshipId) async {
    try {
      final res = await client
          .from('caregiver_permissions')
          .select()
          .eq('relationship_id', relationshipId)
          .maybeSingle();
      if (res == null) return null;
      return CaregiverPermissions.fromJson(res);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updatePermissions(CaregiverPermissions permissions) async {
    try {
      await client.from('caregiver_permissions').update({
        'can_view_task_titles': permissions.canViewTaskTitles,
        'can_view_task_steps': permissions.canViewTaskSteps,
        'can_view_progress': permissions.canViewProgress,
        'can_view_missed_routines': permissions.canViewMissedRoutines,
        'can_view_body_double_summaries':
            permissions.canViewBodyDoubleSummaries,
        'can_view_safety_alerts': permissions.canViewSafetyAlerts,
        'can_assign_tasks': permissions.canAssignTasks,
        'can_assign_routines': permissions.canAssignRoutines,
        'can_set_reminders': permissions.canSetReminders,
        'can_suggest_side_quests': permissions.canSuggestSideQuests,
        'can_invite_body_double': permissions.canInviteBodyDouble,
        'can_approve_random_body_double':
            permissions.canApproveRandomBodyDouble,
        'can_archive_assignments': permissions.canArchiveAssignments,
        'only_view_assigned_tasks': permissions.onlyViewAssignedTasks,
        'only_view_caregiver_routines': permissions.onlyViewCaregiverRoutines,
        'only_view_summaries': permissions.onlyViewSummaries,
        'support_hours_json': permissions.supportHoursJson,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', permissions.id);
    } catch (_) {}
  }

  @override
  Future<List<CaregiverAssignedTask>> loadAssignedTasks(
      {String? targetUserId}) async {
    if (userId == null) return [];
    try {
      var query = client.from('caregiver_assigned_tasks').select('''
        *,
        task:task_id(title)
      ''');

      if (targetUserId != null) {
        query = query.eq('target_user_id', targetUserId);
      } else {
        query =
            query.or('caregiver_user_id.eq.$userId,target_user_id.eq.$userId');
      }

      final res = await query;
      return (res as List<dynamic>).map((json) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(json);
        data['task_title'] = json['task']?['title'];
        return CaregiverAssignedTask.fromJson(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> assignTask({
    required String targetUserId,
    required String taskTitle,
    List<String>? steps,
    DateTime? dueAt,
    String visibilityLevel = 'standard',
  }) async {
    if (userId == null) return;
    try {
      await client.from('caregiver_assigned_tasks').insert({
        'caregiver_user_id': userId,
        'target_user_id': targetUserId,
        'task_title': taskTitle,
        'steps': steps,
        'due_at': dueAt?.toIso8601String(),
        'visibility_level': visibilityLevel,
        'status': 'suggested',
      });
    } catch (_) {}
  }

  @override
  Future<void> respondToAssignedTask({
    required String assignedTaskId,
    required CaregiverTaskStatus status,
  }) async {
    try {
      await client.from('caregiver_assigned_tasks').update({
        'status': status.name,
        'accepted_at': status == CaregiverTaskStatus.accepted
            ? DateTime.now().toIso8601String()
            : null,
        'completed_at': status == CaregiverTaskStatus.completed
            ? DateTime.now().toIso8601String()
            : null,
      }).eq('id', assignedTaskId);
    } catch (_) {}
  }

  @override
  Future<List<CaregiverAssignedRoutine>> loadAssignedRoutines(
      {String? targetUserId}) async {
    if (userId == null) return [];
    try {
      var query = client.from('caregiver_assigned_routines').select('''
        *,
        routine:routine_id(title)
      ''');

      if (targetUserId != null) {
        query = query.eq('target_user_id', targetUserId);
      } else {
        query =
            query.or('caregiver_user_id.eq.$userId,target_user_id.eq.$userId');
      }

      final res = await query;
      return (res as List<dynamic>).map((json) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(json);
        data['routine_title'] = json['routine']?['title'];
        return CaregiverAssignedRoutine.fromJson(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> assignRoutine({
    required String targetUserId,
    required String routineId,
  }) async {
    if (userId == null) return;
    try {
      await client.from('caregiver_assigned_routines').insert({
        'caregiver_user_id': userId,
        'target_user_id': targetUserId,
        'routine_id': routineId,
        'status': 'active',
      });
    } catch (_) {}
  }

  @override
  Future<void> suggestSideQuest({
    required String targetUserId,
    required String title,
  }) async {
    if (userId == null) return;
    try {
      await client.from('side_quests').insert({
        'user_id': targetUserId,
        'title': title,
        'status': 'suggested',
        'suggested_by': userId,
      });
    } catch (_) {}
  }

  @override
  Future<void> sendNudge({
    required String relationshipId,
    required String targetUserId,
    required String message,
  }) async {
    if (userId == null) return;
    try {
      await client.from('caregiver_check_ins').insert({
        'relationship_id': relationshipId,
        'sender_id': userId,
        'receiver_id': targetUserId,
        'message': message,
        'check_in_type': 'encouragement',
      });
    } catch (_) {}
  }

  @override
  Future<void> setMinorRandomApproval({
    required String targetUserId,
    required bool approved,
  }) async {
    if (userId == null) return;
    try {
      await client.rpc('set_guardian_random_approval', params: {
        'p_target_user_id': targetUserId,
        'p_approved': approved,
      });
    } catch (_) {}
  }

  @override
  Future<void> inviteToBodyDouble({
    required String targetUserId,
    required String taskCategory,
    int durationMinutes = 25,
  }) async {
    if (userId == null) return;
    try {
      final sessionRes = await client
          .from('body_double_sessions')
          .insert({
            'creator_id': userId,
            'session_type': 'friend',
            'task_category': taskCategory,
            'status': 'waiting',
          })
          .select('id')
          .single();

      final sessionId = sessionRes['id'] as String;

      await client.from('body_double_invites').insert({
        'session_id': sessionId,
        'sender_id': userId,
        'receiver_id': targetUserId,
        'status': 'pending',
      });
    } catch (_) {}
  }

  @override
  Future<List<CaregiverAlert>> loadAlerts(String relationshipId) async {
    try {
      final res = await client
          .from('caregiver_alerts')
          .select()
          .eq('relationship_id', relationshipId)
          .order('created_at', ascending: false)
          .limit(10);
      return (res as List<dynamic>)
          .map((json) => CaregiverAlert.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<BodyDoubleSession>> loadBodyDoubleSummaries(String userId) async {
    try {
      final res = await client
          .from('body_double_sessions')
          .select()
          .eq('status', 'completed')
          .filter('participants', 'cs', '{"user_id": "$userId"}')
          .order('created_at', ascending: false)
          .limit(5);
      return (res as List<dynamic>)
          .map((json) => BodyDoubleSession.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<String> exportProgressReport(String userId) async {
    await Future.delayed(const Duration(seconds: 2));
    return 'https://api.dopeimine.com/reports/export_$userId.pdf';
  }
}
