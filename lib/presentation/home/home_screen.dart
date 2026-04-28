import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/primary_scaffold.dart';
import '../../providers.dart';
import '../auth/auth_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PrimaryScaffold(
      title: 'Dope-i-Mine',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'What do you need to do?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/tasks/new'),
              child: const Text('Create task'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                final authUser =
                    ref.read(authRepositoryProvider).getCurrentUser();
                if (authUser != null) {
                  await ref
                      .read(profileRepositoryProvider)
                      .setOnboardingCompleted(
                        userId: authUser.id,
                        email: authUser.email,
                        completed: false,
                      );
                }
                if (context.mounted) context.go('/branding/intro');
              },
              child: const Text('Restart onboarding'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.go('/routines'),
              child: const Text('View routines'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.go('/progress'),
              child: const Text('View progress'),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () async {
                await ref.read(authControllerProvider).signOut();
                if (context.mounted) context.go('/');
              },
              child: const Text('Sign out'),
            ),
          ),
        ],
      ),
    );
  }
}
