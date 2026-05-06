class AvatarV4SyncFailure implements Exception {
  const AvatarV4SyncFailure(
    this.message, {
    required this.code,
  });

  final String message;
  final String code;

  @override
  String toString() => 'AvatarV4SyncFailure($code): $message';
}

class AvatarV4OfflineUpdateFailure extends AvatarV4SyncFailure {
  const AvatarV4OfflineUpdateFailure()
      : super(
          'Avatar changes require an online connection so the profile, purchases, and unlocked items stay synced.',
          code: 'avatar_update_requires_online',
        );
}
