import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_back_button.dart';
import '../../domain/caregiver/caregiver_models.dart';
import '../../providers.dart';
import '../core/widgets/empty_state_card.dart';
import 'caregiver_controller.dart';
import 'linked_user_detail_screen.dart';

class CaregiverDashboardScreen extends ConsumerStatefulWidget {
  const CaregiverDashboardScreen({super.key, this.inviteId});

  final String? inviteId;

  @override
  ConsumerState<CaregiverDashboardScreen> createState() =>
      _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState
    extends ConsumerState<CaregiverDashboardScreen> {
  bool _inviteHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _acceptInviteFromLink());
  }

  Future<void> _acceptInviteFromLink() async {
    final inviteId = widget.inviteId?.trim();
    if (_inviteHandled || inviteId == null || inviteId.isEmpty) return;
    _inviteHandled = true;
    final controller = ref.read(caregiverControllerProvider.notifier);
    final accepted = await controller.acceptEmailInvite(inviteId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          accepted
              ? 'Caregiver invite accepted. If you need to create a password, check your inbox.'
              : 'Could not accept caregiver invite.',
        ),
      ),
    );
    if (accepted) context.go('/caregiver');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(caregiverControllerProvider);
    final linkedDashboard = _linkedDashboardForCaregiver(state);
    if (linkedDashboard != null) return linkedDashboard;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Caregiver Support'),
        actions: [
          IconButton(
            tooltip: 'Avatar engine',
            icon: const Icon(Icons.face_retouching_natural_rounded),
            onPressed: () => context.push('/avatar/customize'),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.read(caregiverControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.isLoading &&
              state.relationships.isEmpty &&
              state.emailInvites.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(caregiverControllerProvider.notifier).refresh(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _DashboardHeader(
                    hasLinks: state.relationships.isNotEmpty,
                  ),
                  const SizedBox(height: 24),
                  if (state.relationships.isEmpty && state.emailInvites.isEmpty)
                    const EmptyStateCard(
                      title: 'No active support links',
                      subtitle:
                          'Invite a trusted person to help you manage your routines and tasks.',
                    )
                  else ...[
                    if (state.emailInvites.isNotEmpty) ...[
                      Text(
                        'Pending email invites',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ...state.emailInvites
                          .map((invite) => _EmailInviteCard(invite: invite)),
                      const SizedBox(height: 24),
                    ],
                    if (state.relationships.isNotEmpty) ...[
                      Text(
                        'Linked People',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ...state.relationships
                          .map((rel) => _RelationshipCard(relationship: rel)),
                    ],
                  ],
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () => context.push('/caregiver/link'),
                    icon: const Icon(Icons.person_add_rounded),
                    label: const Text('Add Support Person'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/settings'),
                          icon: const Icon(Icons.settings_rounded),
                          label: const Text('Settings'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/avatar/customize'),
                          icon:
                              const Icon(Icons.face_retouching_natural_rounded),
                          label: const Text('Avatar'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Support, not surveillance. You choose exactly what each person can see and do.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }

  Widget? _linkedDashboardForCaregiver(CaregiverState state) {
    if (widget.inviteId != null) return null;
    if (state.isLoading || state.relationships.isEmpty) return null;

    final authUser = ref.read(authRepositoryProvider).getCurrentUser();
    if (authUser == null) return null;

    final activeCaregiverRelationships = state.relationships.where((rel) {
      return rel.status == CaregiverRelationshipStatus.accepted &&
          rel.caregiverUserId == authUser.id;
    }).toList();

    if (activeCaregiverRelationships.isEmpty) return null;

    return LinkedUserDetailScreen(
      relationshipId: activeCaregiverRelationships.first.id,
    );
  }
}

class _EmailInviteCard extends ConsumerWidget {
  const _EmailInviteCard({required this.invite});

  final CaregiverEmailInvite invite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      key: ValueKey<String>('caregiver-pending-invite-${invite.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.email_outlined)),
        title: Text(invite.inviteeEmail),
        subtitle: Text(
          '${invite.role.name.toUpperCase()} • pending invite',
        ),
        trailing: IconButton(
          key: ValueKey<String>('cancel-caregiver-invite-${invite.id}'),
          tooltip: 'Cancel pending invite',
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: () => _confirmCancelInvite(context, ref, invite),
        ),
      ),
    );
  }

  Future<void> _confirmCancelInvite(
    BuildContext context,
    WidgetRef ref,
    CaregiverEmailInvite invite,
  ) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel pending invite?'),
        content: Text(
          'This will remove the pending caregiver invite for ${invite.inviteeEmail}. They will not be able to accept this invite afterwards.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep invite'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cancel invite'),
          ),
        ],
      ),
    );

    if (shouldCancel != true || !context.mounted) return;

    await ref
        .read(caregiverControllerProvider.notifier)
        .cancelPendingInvite(invite.id);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invite for ${invite.inviteeEmail} cancelled.')),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final bool hasLinks;
  const _DashboardHeader({required this.hasLinks});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.teal.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_rounded, color: Colors.white, size: 32),
          const SizedBox(height: 16),
          Text(
            hasLinks ? 'Support Active' : 'Help & Support',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Managing executive function is easier together. Link a caregiver to share the load.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _RelationshipCard extends ConsumerWidget {
  final CaregiverRelationship relationship;
  const _RelationshipCard({required this.relationship});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending =
        relationship.status == CaregiverRelationshipStatus.pending;
    final roleColor = switch (relationship.role) {
      CaregiverRole.overseer => Colors.purple.shade200,
      CaregiverRole.caregiver => Colors.blue.shade200,
      CaregiverRole.monitor => Colors.teal.shade200,
    };

    return Card(
      key: ValueKey<String>('caregiver-relationship-${relationship.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/caregiver/user/${relationship.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: roleColor.withOpacity(0.2),
                child: Icon(
                  isPending
                      ? Icons.hourglass_top_rounded
                      : Icons.person_rounded,
                  color: roleColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      relationship.relationshipLabel ??
                          relationship.caregiverName ??
                          relationship.supportedName ??
                          'Support person',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${relationship.role.name.toUpperCase()} • ${relationship.status.name}',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
              if (isPending)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      key: ValueKey<String>(
                        'accept-caregiver-relationship-${relationship.id}',
                      ),
                      tooltip: 'Accept caregiver request',
                      icon: const Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                      onPressed: () => ref
                          .read(caregiverControllerProvider.notifier)
                          .respondToRequest(relationship.id, true),
                    ),
                    IconButton(
                      key: ValueKey<String>(
                        'decline-caregiver-relationship-${relationship.id}',
                      ),
                      tooltip: 'Decline caregiver request',
                      icon:
                          const Icon(Icons.cancel_outlined, color: Colors.red),
                      onPressed: () => ref
                          .read(caregiverControllerProvider.notifier)
                          .respondToRequest(relationship.id, false),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      key: ValueKey<String>(
                        'remove-caregiver-relationship-${relationship.id}',
                      ),
                      tooltip: 'Remove support link',
                      icon: const Icon(Icons.link_off_rounded),
                      onPressed: () => _confirmRemoveRelationship(
                          context, ref, relationship),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmRemoveRelationship(
    BuildContext context,
    WidgetRef ref,
    CaregiverRelationship relationship,
  ) async {
    final displayName = relationship.relationshipLabel ??
        relationship.caregiverName ??
        relationship.supportedName ??
        'this support person';

    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove caregiver?'),
        content: Text(
          'This removes the active support link with $displayName. They will no longer be able to view or manage your caregiver support features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep link'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove link'),
          ),
        ],
      ),
    );

    if (shouldRemove != true || !context.mounted) return;

    await ref
        .read(caregiverControllerProvider.notifier)
        .revokeRelationship(relationship.id);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Support link with $displayName removed.')),
    );
  }
}
