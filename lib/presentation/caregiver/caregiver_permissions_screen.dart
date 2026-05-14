import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_back_button.dart';
import '../../domain/caregiver/caregiver_models.dart';
import 'caregiver_controller.dart';

class CaregiverPermissionsScreen extends ConsumerStatefulWidget {
  final String relationshipId;
  const CaregiverPermissionsScreen({super.key, required this.relationshipId});

  @override
  ConsumerState<CaregiverPermissionsScreen> createState() => _CaregiverPermissionsScreenState();
}

class _CaregiverPermissionsScreenState extends ConsumerState<CaregiverPermissionsScreen> {
  CaregiverPermissions? _permissions;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final perms = await ref.read(caregiverRepositoryProvider).loadPermissions(widget.relationshipId);
    if (mounted) {
      setState(() {
        _permissions = perms;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_permissions == null) return const Scaffold(body: Center(child: Text('Permissions not found')));

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Support Permissions'),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(caregiverRepositoryProvider).updatePermissions(_permissions!);
              if (mounted) context.pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(title: 'What they can see'),
          _PermissionSwitch(
            title: 'Task Titles',
            value: _permissions!.canViewTaskTitles,
            onChanged: (val) => setState(() => _permissions = _permissions!.copyWith(canViewTaskTitles: val)),
          ),
          _PermissionSwitch(
            title: 'Task Steps',
            value: _permissions!.canViewTaskSteps,
            onChanged: (val) => setState(() => _permissions = _permissions!.copyWith(canViewTaskSteps: val)),
          ),
          _PermissionSwitch(
            title: 'Overall Progress',
            value: _permissions!.canViewProgress,
            onChanged: (val) => setState(() => _permissions = _permissions!.copyWith(canViewProgress: val)),
          ),
          _PermissionSwitch(
            title: 'Missed Routines',
            value: _permissions!.canViewMissedRoutines,
            onChanged: (val) => setState(() => _permissions = _permissions!.copyWith(canViewMissedRoutines: val)),
          ),
          const Divider(),
          _SectionHeader(title: 'What they can do'),
          _PermissionSwitch(
            title: 'Assign Tasks',
            value: _permissions!.canAssignTasks,
            onChanged: (val) => setState(() => _permissions = _permissions!.copyWith(canAssignTasks: val)),
          ),
          _PermissionSwitch(
            title: 'Assign Routines',
            value: _permissions!.canAssignRoutines,
            onChanged: (val) => setState(() => _permissions = _permissions!.copyWith(canAssignRoutines: val)),
          ),
          _PermissionSwitch(
            title: 'Invite to Body Double',
            value: _permissions!.canInviteBodyDouble,
            onChanged: (val) => setState(() => _permissions = _permissions!.copyWith(canInviteBodyDouble: val)),
          ),
          _PermissionSwitch(
            title: 'Approve Random Matching (Minors)',
            value: _permissions!.canApproveRandomBodyDouble,
            onChanged: (val) async {
              setState(() => _permissions = _permissions!.copyWith(canApproveRandomBodyDouble: val));
              // Also update the core safety settings for the minor
              final rel = ref.read(caregiverControllerProvider).relationships.firstWhere((r) => r.id == widget.relationshipId);
              await ref.read(caregiverControllerProvider.notifier).setMinorRandomApproval(rel.supportedUserId, val);
            },
          ),
          const Divider(),
          _SectionHeader(title: 'Restrictions'),
          _PermissionSwitch(
            title: 'Only view tasks they assigned',
            value: _permissions!.onlyViewAssignedTasks,
            onChanged: (val) => setState(() => _permissions = _permissions!.copyWith(onlyViewAssignedTasks: val)),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () {
              // Revoke logic
            },
            icon: const Icon(Icons.no_accounts_rounded, color: Colors.red),
            label: const Text('Revoke Support Access', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade400,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _PermissionSwitch extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PermissionSwitch({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}

// Extension to help with copyWith on permissions
extension on CaregiverPermissions {
  CaregiverPermissions copyWith({
    bool? canViewTaskTitles,
    bool? canViewTaskSteps,
    bool? canViewProgress,
    bool? canViewMissedRoutines,
    bool? canAssignTasks,
    bool? canAssignRoutines,
    bool? canInviteBodyDouble,
    bool? canApproveRandomBodyDouble,
    bool? onlyViewAssignedTasks,
  }) {
    return CaregiverPermissions(
      id: id,
      relationshipId: relationshipId,
      canViewTaskTitles: canViewTaskTitles ?? this.canViewTaskTitles,
      canViewTaskSteps: canViewTaskSteps ?? this.canViewTaskSteps,
      canViewProgress: canViewProgress ?? this.canViewProgress,
      canViewMissedRoutines: canViewMissedRoutines ?? this.canViewMissedRoutines,
      canAssignTasks: canAssignTasks ?? this.canAssignTasks,
      canAssignRoutines: canAssignRoutines ?? this.canAssignRoutines,
      canInviteBodyDouble: canInviteBodyDouble ?? this.canInviteBodyDouble,
      canApproveRandomBodyDouble: canApproveRandomBodyDouble ?? this.canApproveRandomBodyDouble,
      onlyViewAssignedTasks: onlyViewAssignedTasks ?? this.onlyViewAssignedTasks,
    );
  }
}
