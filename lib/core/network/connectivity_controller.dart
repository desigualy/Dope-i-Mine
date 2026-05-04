import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connectivity_status.dart';

final connectivityControllerProvider =
    StateNotifierProvider<ConnectivityController, ConnectivityStatus>((ref) {
  return ConnectivityController();
});

class ConnectivityController extends StateNotifier<ConnectivityStatus> {
  ConnectivityController({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        super(ConnectivityStatus.unknown) {
    _init();
  }

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _pollTimer;
  bool _disposed = false;

  Future<void> _init() async {
    await refresh();
    if (_disposed) return;

    _subscription = _connectivity.onConnectivityChanged.listen((_) {
      unawaited(refresh());
    });

    // Android emulators do not always emit a connectivity event when network
    // is toggled from Quick Settings. Poll lightly so the offline banner and
    // Settings panel stay honest during real use.
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      unawaited(refresh());
    });
  }

  Future<ConnectivityStatus> refresh() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final linkStatus = _statusFromResults(results);
      if (linkStatus == ConnectivityStatus.offline) {
        _setStatus(ConnectivityStatus.offline);
        return state;
      }

      final hasInternet = await _hasInternetRoute();
      _setStatus(hasInternet ? ConnectivityStatus.online : ConnectivityStatus.offline);
    } catch (_) {
      _setStatus(ConnectivityStatus.unknown);
    }
    return state;
  }

  bool get isOnline => state == ConnectivityStatus.online;

  void _setStatus(ConnectivityStatus status) {
    if (_disposed || !mounted) return;
    if (state == status) return;
    state = status;
  }

  ConnectivityStatus _statusFromResults(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return ConnectivityStatus.offline;
    }
    return ConnectivityStatus.online;
  }

  Future<bool> _hasInternetRoute() async {
    if (kIsWeb) return true;
    try {
      final lookup = await InternetAddress.lookup('one.one.one.one')
          .timeout(const Duration(seconds: 2));
      return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _pollTimer?.cancel();
    _pollTimer = null;
    final subscription = _subscription;
    _subscription = null;
    unawaited(subscription?.cancel());
    super.dispose();
  }
}
