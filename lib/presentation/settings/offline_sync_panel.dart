import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/connectivity_controller.dart';
import '../../core/network/connectivity_status.dart';
import '../../core/sync/sync_status_controller.dart';
import '../../providers.dart';

class OfflineSyncPanel extends ConsumerWidget {
  const OfflineSyncPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityControllerProvider);
    final sync = ref.watch(syncStatusControllerProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  connectivity == ConnectivityStatus.online
                      ? Icons.cloud_done_rounded
                      : Icons.cloud_off_rounded,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Offline and sync status',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Connection: ${connectivity.label}'),
            Text('Pending sync items: ${sync.pendingCount}'),
            Text(
              'Last sync: ${sync.lastSyncAt?.toLocal().toString() ?? 'Not yet'}',
            ),
            if (sync.lastError != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                'Last sync issue: ${sync.lastError}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: () => ref
                      .read(connectivityControllerProvider.notifier)
                      .refresh(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Check connection'),
                ),
                ElevatedButton.icon(
                  onPressed: connectivity == ConnectivityStatus.online
                      ? () async {
                          await ref.read(syncEngineProvider).syncNow();
                          await ref
                              .read(syncStatusControllerProvider.notifier)
                              .refresh();
                        }
                      : null,
                  icon: const Icon(Icons.sync_rounded),
                  label: const Text('Retry sync'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
