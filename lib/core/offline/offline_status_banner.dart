import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/connectivity_controller.dart';
import '../network/connectivity_status.dart';
import '../sync/sync_status_controller.dart';

class OfflineStatusBanner extends ConsumerWidget {
  const OfflineStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectivityControllerProvider);
    final syncStatus = ref.watch(syncStatusControllerProvider);
    final pendingCount = syncStatus.pendingCount;

    if (status == ConnectivityStatus.online && pendingCount == 0) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final offline = status != ConnectivityStatus.online;

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: offline
              ? colorScheme.errorContainer.withOpacity(0.85)
              : colorScheme.primaryContainer.withOpacity(0.85),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              offline ? Icons.cloud_off_rounded : Icons.sync_rounded,
              color: offline
                  ? colorScheme.onErrorContainer
                  : colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                offline
                    ? 'You’re offline. Dope-i-Mine will keep working and sync when connected.'
                    : 'Sync pending: $pendingCount item${pendingCount == 1 ? '' : 's'} waiting.',
                style: TextStyle(
                  color: offline
                      ? colorScheme.onErrorContainer
                      : colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
