enum SyncQueueStatus { pending, syncing, synced, failed }

class SyncQueueItem {
  const SyncQueueItem({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    required this.idempotencyKey,
    this.status = SyncQueueStatus.pending,
    this.attempts = 0,
    this.lastError,
    this.updatedAt,
  });

  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final String idempotencyKey;
  final SyncQueueStatus status;
  final int attempts;
  final String? lastError;
  final DateTime? updatedAt;

  bool get shouldAttempt =>
      status == SyncQueueStatus.pending || status == SyncQueueStatus.failed;

  SyncQueueItem copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    String? idempotencyKey,
    SyncQueueStatus? status,
    int? attempts,
    String? lastError,
    DateTime? updatedAt,
    bool clearLastError = false,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory SyncQueueItem.create({
    required String type,
    required Map<String, dynamic> payload,
    String? idempotencyKey,
  }) {
    final now = DateTime.now().toUtc();
    final stableKey = idempotencyKey ?? '${type}_${now.microsecondsSinceEpoch}';
    return SyncQueueItem(
      id: 'sync_${now.microsecondsSinceEpoch}_${stableKey.hashCode.abs()}',
      type: type,
      payload: payload,
      createdAt: now,
      idempotencyKey: stableKey,
    );
  }

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'] as String,
      type: json['type'] as String,
      payload: (json['payload'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{},
      createdAt: DateTime.parse(json['createdAt'] as String),
      idempotencyKey: json['idempotencyKey'] as String,
      status: _statusFromName(json['status'] as String?),
      attempts: json['attempts'] as int? ?? 0,
      lastError: json['lastError'] as String?,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': type,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
      'idempotencyKey': idempotencyKey,
      'status': status.name,
      'attempts': attempts,
      'lastError': lastError,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static SyncQueueStatus _statusFromName(String? value) {
    for (final status in SyncQueueStatus.values) {
      if (status.name == value) return status;
    }
    return SyncQueueStatus.pending;
  }
}
