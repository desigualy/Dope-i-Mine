import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_failure.dart';

String mapToUserFacingError(Object error) {
  if (error is AppFailure) {
    return error.message;
  }
  
  if (error is AuthException) {
    switch (error.code) {
      case 'invalid_credentials':
        return 'Invalid email or password.';
      case 'email_not_confirmed':
        return 'Please confirm your email address.';
      default:
        return error.message;
    }
  }

  if (error is PostgrestException) {
    return 'Database error: ${error.message}';
  }

  if (error.toString().contains('network_error') || error.toString().contains('SocketException')) {
    return 'Network error. Please check your connection.';
  }

  return 'Something went wrong. Please try again.';
}
