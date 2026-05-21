import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sync_queue_service.dart';

final syncStatusControllerProvider =
    StateNotifierProvider<SyncStatusController, SyncStatusState>((ref) {
  return SyncStatusController(ref.read(syncQueueServiceProvider));
});

class SyncStatusState {
  const SyncStatusState({
    this.pendingCount = 0,
    this.failedCount = 0,
    this.lastSyncAt,
    this.loading = false,
    this.lastError,
  });

  final int pendingCount;
  final int failedCount;
  final DateTime? lastSyncAt;
  final bool loading;
  final String? lastError;

  SyncStatusState copyWith({
    int? pendingCount,
    int? failedCount,
    DateTime? lastSyncAt,
    bool? loading,
    String? lastError,
    bool clearError = false,
  }) {
    return SyncStatusState(
      pendingCount: pendingCount ?? this.pendingCount,
      failedCount: failedCount ?? this.failedCount,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      loading: loading ?? this.loading,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }
}

class SyncStatusController extends StateNotifier<SyncStatusState> {
  SyncStatusController(this._queueService) : super(const SyncStatusState()) {
    refresh();
  }

  final SyncQueueService _queueService;

  Future<void> refresh() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final pending = await _queueService.pendingCount();
      final failed = await _queueService.failedCount();
      final lastSync = await _queueService.lastSyncAt();
      state = SyncStatusState(
        pendingCount: pending,
        failedCount: failed,
        lastSyncAt: lastSync,
      );
    } catch (error) {
      state = state.copyWith(loading: false, lastError: error.toString());
    }
  }
}
