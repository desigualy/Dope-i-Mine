import 'package:flutter_test/flutter_test.dart';

import 'package:dope_i_mine/app/session_redirect.dart';

void main() {
  group('sessionRedirect', () {
    test('redirects unauthenticated users away from protected routes', () {
      expect(
        sessionRedirect(authenticated: false, location: '/home'),
        '/login',
      );
    });

    test('allows unauthenticated users to access public auth routes', () {
      expect(sessionRedirect(authenticated: false, location: '/'), isNull);
      expect(sessionRedirect(authenticated: false, location: '/login'), isNull);
      expect(
          sessionRedirect(authenticated: false, location: '/signup'), isNull);
    });

    test('does not preempt login after authentication', () {
      expect(
        sessionRedirect(authenticated: true, location: '/login'),
        isNull,
      );
    });

    test('does not preempt signup after authentication', () {
      expect(
        sessionRedirect(authenticated: true, location: '/signup'),
        isNull,
      );
    });

    test('leaves welcome routing to the onboarding gate', () {
      expect(
        sessionRedirect(authenticated: true, location: '/'),
        isNull,
      );
    });
  });
}
