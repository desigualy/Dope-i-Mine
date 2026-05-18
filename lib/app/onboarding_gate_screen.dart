import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/auth/auth_user.dart';
import '../providers.dart';

class OnboardingGateScreen extends ConsumerWidget {
  const OnboardingGateScreen({
    super.key,
    required this.child,
    this.unauthenticatedChild,
    this.completedTarget,
  });

  final Widget child;
  final Widget? unauthenticatedChild;
  final String? completedTarget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = _readCurrentUser(ref);

    if (authUser == null) {
      return unauthenticatedChild ?? const _GateLoadingScreen();
    }

    return FutureBuilder<_GateDecision>(
      future: _loadGateDecision(ref, authUser),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _GateLoadingScreen();
        }

        final decision = snapshot.data ?? const _GateDecision();
        final target = decision.mustChangePassword
            ? '/force-password-change'
            : decision.accountType == 'caregiver'
                ? decision.onboardingComplete
                    ? '/caregiver'
                    : '/caregiver/confirm'
                : decision.onboardingComplete
                    ? completedTarget
                    : '/branding/intro';

        if (target != null &&
            GoRouterState.of(context).matchedLocation != target) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go(target);
          });
          return const _GateLoadingScreen();
        }

        return child;
      },
    );
  }

  AuthUser? _readCurrentUser(WidgetRef ref) {
    try {
      return ref.read(authRepositoryProvider).getCurrentUser();
    } catch (_) {
      return null;
    }
  }

  Future<_GateDecision> _loadGateDecision(
    WidgetRef ref,
    AuthUser authUser,
  ) async {
    try {
      final repo = ref.read(profileRepositoryProvider);
      await repo.ensureProfileExists(
          userId: authUser.id, email: authUser.email);
      final accountType = await repo.getAccountType(authUser.id);
      final onboardingComplete = await repo.isOnboardingComplete(authUser.id);
      final mustChange = await repo.mustChangePassword(authUser.id);
      return _GateDecision(
        accountType: accountType,
        onboardingComplete: onboardingComplete,
        mustChangePassword: mustChange,
      );
    } catch (_) {
      return const _GateDecision();
    }
  }
}

class _GateDecision {
  const _GateDecision({
    this.accountType = 'user',
    this.onboardingComplete = false,
    this.mustChangePassword = false,
  });

  final String accountType;
  final bool onboardingComplete;
  final bool mustChangePassword;
}

class _GateLoadingScreen extends StatelessWidget {
  const _GateLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
