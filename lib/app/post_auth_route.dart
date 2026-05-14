import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/auth/auth_user.dart';
import '../providers.dart';

Future<String> resolvePostAuthRoute(
  WidgetRef ref,
  AuthUser authUser, {
  String accountType = 'user',
}) async {
  final profileRepository = ref.read(profileRepositoryProvider);
  await profileRepository.ensureProfileExists(
    userId: authUser.id,
    email: authUser.email,
    accountType: accountType,
  );

  final resolvedAccountType =
      await profileRepository.getAccountType(authUser.id);
  if (resolvedAccountType == 'caregiver') {
    return '/caregiver';
  }

  final onboardingComplete =
      await profileRepository.isOnboardingComplete(authUser.id);
  return onboardingComplete ? '/home' : '/branding/intro';
}
