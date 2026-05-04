class OfflineModeSnapshot {
  const OfflineModeSnapshot({
    required this.isOffline,
    required this.pendingSyncCount,
    this.lastSyncAt,
    this.message,
  });

  final bool isOffline;
  final int pendingSyncCount;
  final DateTime? lastSyncAt;
  final String? message;

  OfflineModeSnapshot copyWith({
    bool? isOffline,
    int? pendingSyncCount,
    DateTime? lastSyncAt,
    String? message,
  }) {
    return OfflineModeSnapshot(
      isOffline: isOffline ?? this.isOffline,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      message: message ?? this.message,
    );
  }
}
