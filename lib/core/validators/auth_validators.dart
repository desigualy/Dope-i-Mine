import '../errors/app_failure.dart';

void validateEmail(String value) { if (value.trim().isEmpty || !value.contains('@')) { throw const AppFailure('Please enter a valid email address.', code: 'invalid_email'); } }
void validatePassword(String value) { if (value.length < 8) { throw const AppFailure('Password must be at least 8 characters.', code: 'weak_password'); } }
