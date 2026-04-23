import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../domain/auth/auth_user.dart';

class AuthRepositoryImpl {
  AuthRepositoryImpl(this._client);

  final SupabaseClient _client;

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    await _client.auth.signUp(email: email, password: password);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  AuthUser? getCurrentUser() {
    final user = _client.auth.currentUser;
    if (user == null || user.email == null) {
      return null;
    }
    return AuthUser(
      id: user.id,
      email: user.email!,
    );
  }
}
