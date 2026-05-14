import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_back_button.dart';
import '../../domain/caregiver/caregiver_models.dart';
import '../core/widgets/empty_state_card.dart';
import 'caregiver_controller.dart';

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
    final accepted = await ref
        .read(caregiverControllerProvider.notifier)
        .acceptEmailInvite(inviteId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(accepted
            ? 'Caregiver invite accepted.'
            : 'Could not accept caregiver invite.'),
      ),
    );
    if (accepted) context.go('/caregiver');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(caregiverControllerProvider);

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
}

class _EmailInviteCard extends StatelessWidget {
  const _EmailInviteCard({required this.invite});

  final CaregiverEmailInvite invite;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.email_outlined)),
        title: Text(invite.inviteeEmail),
        subtitle:
            Text('${invite.role.name.toUpperCase()} • ${invite.status.name}'),
        trailing: const Icon(Icons.hourglass_top_rounded),
      ),
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
                          'Unknown',
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
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.green),
                      onPressed: () => ref
                          .read(caregiverControllerProvider.notifier)
                          .respondToRequest(relationship.id, true),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.cancel_outlined, color: Colors.red),
                      onPressed: () => ref
                          .read(caregiverControllerProvider.notifier)
                          .respondToRequest(relationship.id, false),
                    ),
                  ],
                )
              else
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
