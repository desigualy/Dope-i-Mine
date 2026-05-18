import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../domain/auth/auth_user.dart';

class AuthRepositoryImpl {
  AuthRepositoryImpl(this._client);

  final SupabaseClient _client;
  static const String _authRedirectTo = String.fromEnvironment(
    'APP_AUTH_REDIRECT_TO',
  );
  static const String _passwordResetRedirectTo = String.fromEnvironment(
    'APP_PASSWORD_RESET_REDIRECT_TO',
  );
  static const String _fallbackPasswordResetRedirectTo =
      'https://dope-i-mine.app/reset-password';

  Future<AuthUser?> signUp({
    required String email,
    required String password,
    String accountType = 'user',
  }) async {
    final normalizedAccountType =
        accountType == 'caregiver' ? 'caregiver' : 'user';
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: _authRedirectTo.isEmpty ? null : _authRedirectTo,
      data: <String, dynamic>{'account_type': normalizedAccountType},
    );
    final user = response.user;
    if (user == null || user.email == null) {
      return null;
    }
    return AuthUser(
      id: user.id,
      email: user.email!,
    );
  }

  Future<AuthUser?> signIn({
    required String email,
    required String password,
  }) async {
    final response =
        await _client.auth.signInWithPassword(email: email, password: password);
    final user = response.user;
    if (user == null || user.email == null) {
      return null;
    }
    return AuthUser(
      id: user.id,
      email: user.email!,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  AuthUser? getCurrentUser() {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }
    return AuthUser(
      id: user.id,
      email: user.email ?? '',
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final redirectTo = _passwordResetRedirectTo.isNotEmpty
        ? _passwordResetRedirectTo
        : _authRedirectTo.isNotEmpty
            ? '${_authRedirectTo.replaceFirst(RegExp(r'/$'), '')}/reset-password'
            : _fallbackPasswordResetRedirectTo;

    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: redirectTo,
    );
  }

  Future<void> updatePassword(String password) async {
    await _client.auth.updateUser(UserAttributes(password: password));
  }

  Future<void> completeForcedPasswordChange(String password) async {
    final currentUser = getCurrentUser();
    if (currentUser == null) {
      throw StateError('No user is currently authenticated.');
    }
    
    // 1. call Supabase auth updateUser
    await _client.auth.updateUser(UserAttributes(password: password));
    
    // 2. update users_profile for current user
    await _client.from('users_profile').update(<String, dynamic>{
      'must_change_password': false,
      'temporary_password_created_at': null,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', currentUser.id);
  }
}
