import 'package:flutter/foundation.dart';

import 'route_auth_state_service.dart';

RouteAuthStateService _routeAuthStateService =
    const SupabaseRouteAuthStateService();

/// Injects the route auth state service used by [isAuthenticated].
///
/// Production keeps the default Supabase-backed service. Tests can inject an
/// in-memory implementation so route decisions do not touch Supabase.instance.
@visibleForTesting
void setRouteAuthStateService(RouteAuthStateService service) {
  _routeAuthStateService = service;
}

/// Restores the production Supabase-backed route auth state service.
@visibleForTesting
void resetRouteAuthStateService() {
  _routeAuthStateService = const SupabaseRouteAuthStateService();
}

/// Backwards-compatible test hook for older tests.
@visibleForTesting
void setIsAuthenticatedOverride(bool Function()? override) {
  if (override == null) {
    resetRouteAuthStateService();
    return;
  }

  setRouteAuthStateService(_CallbackRouteAuthStateService(override));
}

/// Backwards-compatible reset hook for older tests.
@visibleForTesting
void clearIsAuthenticatedOverride() {
  resetRouteAuthStateService();
}

bool isAuthenticated() => _routeAuthStateService.isAuthenticated;

class _CallbackRouteAuthStateService implements RouteAuthStateService {
  const _CallbackRouteAuthStateService(this._readAuthenticated);

  final bool Function() _readAuthenticated;

  @override
  bool get isAuthenticated => _readAuthenticated();
}
