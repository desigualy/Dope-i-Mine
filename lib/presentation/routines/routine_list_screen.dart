import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/empty_state_card.dart';
import '../../core/widgets/primary_scaffold.dart';
import '../../providers.dart';
import 'routine_controller.dart';

class RoutineListScreen extends ConsumerStatefulWidget {
  const RoutineListScreen({super.key});

  @override
  ConsumerState<RoutineListScreen> createState() => _RoutineListScreenState();
}

class _RoutineListScreenState extends ConsumerState<RoutineListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authUser = ref.read(authRepositoryProvider).getCurrentUser();
      if (authUser != null) {
        ref.read(routineControllerProvider.notifier).load(authUser.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(routineControllerProvider);
    return PrimaryScaffold(
      title: 'Routines',
      child: state.when(
        data: (routines) {
          if (routines.isEmpty) {
            return const EmptyStateCard(
              title: 'No routines yet',
              subtitle: 'Create your first routine to get started.',
            );
          }
          return ListView.builder(
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final routine = routines[index];
              return ListTile(
                title: Text(routine.title),
                subtitle: Text(routine.ageBand),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load routines')),
      ),
    );
  }
}
