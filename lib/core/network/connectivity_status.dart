enum ConnectivityStatus {
  online,
  offline,
  unknown,
}

extension ConnectivityStatusLabel on ConnectivityStatus {
  bool get isOnline => this == ConnectivityStatus.online;
  bool get isOffline => this == ConnectivityStatus.offline;

  String get label {
    switch (this) {
      case ConnectivityStatus.online:
        return 'Online';
      case ConnectivityStatus.offline:
        return 'Offline';
      case ConnectivityStatus.unknown:
        return 'Checking connection';
    }
  }
}
