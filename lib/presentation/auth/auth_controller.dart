import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/auth/auth_user.dart';
import '../../providers.dart';

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController {
  AuthController(this._ref);

  final Ref _ref;

  Future<AuthUser?> signUp(
    String email,
    String password, {
    String accountType = 'user',
  }) {
    return _ref.read(authRepositoryProvider).signUp(
          email: email,
          password: password,
          accountType: accountType,
        );
  }

  Future<AuthUser?> signIn(String email, String password) {
    return _ref.read(authRepositoryProvider).signIn(
          email: email,
          password: password,
        );
  }

  Future<void> signOut() {
    return _ref.read(authRepositoryProvider).signOut();
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
  }

  Future<void> updatePassword(String password) {
    return _ref.read(authRepositoryProvider).updatePassword(password);
  }
}
