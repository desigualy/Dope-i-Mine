import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/auth/auth_user.dart';
import '../../providers.dart';

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController {
  AuthController(this._ref);

  final Ref _ref;

  Future<AuthUser?> signUp(String email, String password) {
    return _ref.read(authRepositoryProvider).signUp(
          email: email,
          password: password,
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
}
