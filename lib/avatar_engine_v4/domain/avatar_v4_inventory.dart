class AvatarV4Inventory {
  const AvatarV4Inventory({
    this.ownedItemIds = const <String>[],
    this.cachedPackIds = const <String>[],
    this.lastSyncedAtIso,
  });

  final List<String> ownedItemIds;
  final List<String> cachedPackIds;
  final String? lastSyncedAtIso;

  bool owns(String itemId) => ownedItemIds.contains(itemId);
  bool hasCachedPack(String packId) => cachedPackIds.contains(packId);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'ownedItemIds': ownedItemIds,
      'cachedPackIds': cachedPackIds,
      'lastSyncedAtIso': lastSyncedAtIso,
    };
  }

  static AvatarV4Inventory fromJson(Map<String, dynamic> json) {
    return AvatarV4Inventory(
      ownedItemIds: _strings(json['ownedItemIds']),
      cachedPackIds: _strings(json['cachedPackIds']),
      lastSyncedAtIso: json['lastSyncedAtIso'] is String ? json['lastSyncedAtIso'] as String : null,
    );
  }

  static List<String> _strings(Object? value) {
    if (value is Iterable) {
      return value.whereType<String>().where((item) => item.trim().isNotEmpty).toList(growable: false);
    }
    return const <String>[];
  }
}
