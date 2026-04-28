import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

bool Function()? _isAuthenticatedOverride;

/// Test-only hook to override route auth checks.
@visibleForTesting
void setIsAuthenticatedOverride(bool Function()? override) {
  _isAuthenticatedOverride = override;
}

@visibleForTesting
void clearIsAuthenticatedOverride() {
  _isAuthenticatedOverride = null;
}

bool isAuthenticated() {
  if (_isAuthenticatedOverride != null) {
    return _isAuthenticatedOverride!();
  }

  try {
    final user = Supabase.instance.client.auth.currentUser;
    debugPrint('isAuthenticated check: user=$user');
    return user != null;
  } catch (e) {
    debugPrint('isAuthenticated error: $e');
    return false;
  }
}
