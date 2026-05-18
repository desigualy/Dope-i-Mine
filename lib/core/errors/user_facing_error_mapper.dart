import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_failure.dart';

String mapToUserFacingError(Object error) {
  if (error is AppFailure) {
    return error.message;
  }

  // Local validation/state errors (e.g. password mismatch) should be shown as-is.
  if (error is StateError ||
      error is ArgumentError ||
      error is FormatException) {
    final message = error.toString();
    // StateError/ArgumentError often prefix with their type. Keep the user-facing
    // message clean when possible.
    return message
        .replaceFirst(RegExp(r'^StateError:\s*'), '')
        .replaceFirst(RegExp(r'^Invalid argument\(s\)?:\s*'), '')
        .trim();
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

  if (error.toString().contains('network_error') ||
      error.toString().contains('SocketException')) {
    return 'Network error. Please check your connection.';
  }

  return 'Something went wrong. Please try again.';
}
