import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/auth/auth_user.dart';
import '../providers.dart';

Future<String> resolvePostAuthRoute(
  WidgetRef ref,
  AuthUser authUser, {
  String? accountType,
}) async {
  final profileRepository = ref.read(profileRepositoryProvider);

  await profileRepository.ensureProfileExists(
    userId: authUser.id,
    email: authUser.email,
    accountType: accountType ?? 'user',
  );

  final resolvedAccountType =
      await profileRepository.getAccountType(authUser.id);
  final onboardingComplete =
      await profileRepository.isOnboardingComplete(authUser.id);

  final mustChange = await profileRepository.mustChangePassword(authUser.id);
  if (mustChange) {
    return '/force-password-change';
  }

  if (resolvedAccountType == 'caregiver') {
    return onboardingComplete ? '/caregiver' : '/caregiver/confirm';
  }

  return onboardingComplete ? '/home' : '/branding/intro';
}
