import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dope_i_mine/core/sync/sync_queue_service.dart';
import 'package:dope_i_mine/providers.dart';

class HomeSyncStatusCard extends ConsumerWidget {
  const HomeSyncStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FutureBuilder<int>(
          future: ref.read(syncQueueServiceProvider).pendingCount(),
          builder: (context, snapshot) {
            final pending = snapshot.data ?? 0;
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()));
            }

            if (pending == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Sync status', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('All changes saved. We will sync when online.'),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sync status', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('$pending item${pending == 1 ? '' : 's'} pending sync'),
                const SizedBox(height: 8),
                TextButton(onPressed: () async { await ref.read(syncEngineProvider).syncNow(); }, child: const Text('Retry now')),
              ],
            );
          },
        ),
      ),
    );
  }
}
