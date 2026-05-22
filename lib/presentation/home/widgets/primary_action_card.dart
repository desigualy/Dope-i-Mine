import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dope_i_mine/core/sync/sync_queue_service.dart';
import 'package:dope_i_mine/domain/body_double/body_double_session.dart';
import 'package:dope_i_mine/presentation/body_double/body_double_controller.dart';
import 'package:dope_i_mine/providers.dart';

class PrimaryActionCard extends ConsumerWidget {
  const PrimaryActionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Start with one small step',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FutureBuilder(
              future: ref.read(localTaskSessionCacheProvider).load(),
              builder: (context, snapshot) {
                final hasActiveTask = snapshot.data != null;
                final bdState = ref.watch(bodyDoubleControllerProvider);
                final hasActiveBodyDouble = bdState.activeSession != null && bdState.activeSession!.status == BodyDoubleStatus.active;

                String subtitle;
                String buttonLabel;
                VoidCallback? onPressed;

                if (hasActiveBodyDouble) {
                  subtitle = 'Continue your support session';
                  buttonLabel = 'Continue support';
                  onPressed = () => context.go('/body-double/session');
                } else if (hasActiveTask) {
                  subtitle = 'Continue where you left off';
                  buttonLabel = 'Continue task';
                  onPressed = () => context.go('/tasks/breakdown');
                } else {
                  subtitle = 'Pick one thing to begin';
                  buttonLabel = 'Start a task';
                  onPressed = () => context.go('/tasks/new');
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subtitle),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: onPressed,
                          child: Text(buttonLabel),
                        ),
                        const SizedBox(width: 12),
                        FutureBuilder<int>(
                          future: ref.read(syncQueueServiceProvider).pendingCount(),
                          builder: (c, s) {
                            if (s.connectionState != ConnectionState.done || (s.data ?? 0) == 0) return const SizedBox.shrink();
                            return Text('Saved locally — ${s.data} pending sync', style: TextStyle(color: Colors.orange[800]));
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
