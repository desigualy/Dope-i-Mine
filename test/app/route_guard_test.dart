import 'package:flutter_test/flutter_test.dart';
import 'package:dope_i_mine/app/route_auth_state_service.dart';
import 'package:dope_i_mine/app/route_guard.dart';

void main() {
  tearDown(resetRouteAuthStateService);

  test('defaults to unauthenticated when Supabase is unavailable', () {
    resetRouteAuthStateService();

    expect(isAuthenticated(), isFalse);
  });

  test('uses injected route auth state service', () {
    setRouteAuthStateService(
      const InMemoryRouteAuthStateService(authenticated: true),
    );

    expect(isAuthenticated(), isTrue);

    setRouteAuthStateService(
      const InMemoryRouteAuthStateService(authenticated: false),
    );

    expect(isAuthenticated(), isFalse);
  });

  test('keeps legacy bool callback override working', () {
    var authenticated = false;
    setIsAuthenticatedOverride(() => authenticated);

    expect(isAuthenticated(), isFalse);

    authenticated = true;

    expect(isAuthenticated(), isTrue);

    clearIsAuthenticatedOverride();

    expect(isAuthenticated(), isFalse);
  });
}
