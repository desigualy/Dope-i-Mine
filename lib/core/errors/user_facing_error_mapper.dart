import 'app_failure.dart';

String mapToUserFacingError(Object error) {
  if (error is AppFailure) {
    return error.message;
  }
  return 'Something went wrong. Please try again.';
}
