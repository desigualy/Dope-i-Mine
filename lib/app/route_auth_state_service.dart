import 'package:supabase_flutter/supabase_flutter.dart';

/// Synchronous auth snapshot used by the app router.
///
/// The router needs a fast yes/no answer during redirect evaluation. Production
/// reads Supabase's current user here, while tests can inject a deterministic
/// implementation without touching Supabase global state.
abstract interface class RouteAuthStateService {
  const RouteAuthStateService();

  bool get isAuthenticated;
}

/// Production route auth state backed by Supabase Auth.
class SupabaseRouteAuthStateService implements RouteAuthStateService {
  const SupabaseRouteAuthStateService();

  @override
  bool get isAuthenticated {
    try {
      return Supabase.instance.client.auth.currentUser != null;
    } catch (_) {
      // Supabase is intentionally not initialized in several widget tests and
      // can also be absent in local/offline development shells. In those cases
      // the safe routing answer is unauthenticated.
      return false;
    }
  }
}

/// Deterministic route auth state for tests and local harnesses.
class InMemoryRouteAuthStateService implements RouteAuthStateService {
  const InMemoryRouteAuthStateService({required this.authenticated});

  final bool authenticated;

  @override
  bool get isAuthenticated => authenticated;
}
