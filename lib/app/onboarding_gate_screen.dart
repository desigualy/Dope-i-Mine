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

    return FutureBuilder<bool>(
      future: _isOnboardingComplete(ref, authUser),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _GateLoadingScreen();
        }

        final onboardingComplete = snapshot.data == true;
        final target = onboardingComplete ? completedTarget : '/branding/intro';

        if (target != null) {
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

  Future<bool> _isOnboardingComplete(WidgetRef ref, AuthUser authUser) async {
    try {
      final repo = ref.read(profileRepositoryProvider);
      await repo.ensureProfileExists(
          userId: authUser.id, email: authUser.email);
      return await repo.isOnboardingComplete(authUser.id);
    } catch (_) {
      return false;
    }
  }
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
