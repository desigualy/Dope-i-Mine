import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/empty_state_card.dart';
import '../../core/widgets/primary_scaffold.dart';
import '../../providers.dart';
import 'caregiver_controller.dart';

class CaregiverDashboardScreen extends ConsumerStatefulWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  ConsumerState<CaregiverDashboardScreen> createState() =>
      _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState
    extends ConsumerState<CaregiverDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authUser = ref.read(authRepositoryProvider).getCurrentUser();
      if (authUser != null) {
        ref.read(caregiverControllerProvider.notifier).load(authUser.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(caregiverControllerProvider);
    return PrimaryScaffold(
      title: 'Caregiver links',
      child: state.when(
        data: (links) {
          if (links.isEmpty) {
            return const EmptyStateCard(
              title: 'No caregiver links',
              subtitle: 'Link a caregiver when you are ready.',
            );
          }
          return ListView.builder(
            itemCount: links.length,
            itemBuilder: (context, index) {
              final link = links[index];
              return ListTile(
                title: Text(link.permissionLevel),
                subtitle: Text('${link.primaryUserId} → ${link.caregiverUserId}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('Failed to load caregiver links')),
      ),
    );
  }
}
