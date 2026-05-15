import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/primary_scaffold.dart';
import '../../providers.dart';

class CaregiverConfirmScreen extends ConsumerStatefulWidget {
  const CaregiverConfirmScreen({super.key});

  @override
  ConsumerState<CaregiverConfirmScreen> createState() =>
      _CaregiverConfirmScreenState();
}

class _CaregiverConfirmScreenState
    extends ConsumerState<CaregiverConfirmScreen> {
  bool _checking = true;
  bool _saving = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _guardRoute());
  }

  Future<void> _guardRoute() async {
    try {
      final authUser = ref.read(authRepositoryProvider).getCurrentUser();
      if (authUser == null) {
        if (mounted) context.go('/login');
        return;
      }

      final profileRepository = ref.read(profileRepositoryProvider);
      await profileRepository.ensureProfileExists(
        userId: authUser.id,
        email: authUser.email,
      );

      final accountType = await profileRepository.getAccountType(authUser.id);
      final onboardingComplete =
          await profileRepository.isOnboardingComplete(authUser.id);

      if (!mounted) return;

      if (accountType != 'caregiver') {
        context.go(onboardingComplete ? '/home' : '/branding/intro');
        return;
      }

      if (onboardingComplete) {
        context.go('/caregiver');
        return;
      }

      setState(() => _checking = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _checking = false;
        _errorText = 'Could not check caregiver setup. Please try again.';
      });
    }
  }

  Future<void> _confirmCaregiverMode() async {
    setState(() {
      _saving = true;
      _errorText = null;
    });

    try {
      final authUser = ref.read(authRepositoryProvider).getCurrentUser();
      if (authUser == null) {
        if (mounted) context.go('/login');
        return;
      }

      await ref.read(profileRepositoryProvider).setOnboardingCompleted(
            userId: authUser.id,
            email: authUser.email,
            completed: true,
          );

      if (mounted) context.go('/caregiver');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorText = 'Could not confirm caregiver setup. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return PrimaryScaffold(
      title: 'Caregiver setup',
      child: ListView(
        children: <Widget>[
          Icon(
            Icons.volunteer_activism_rounded,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Confirm caregiver mode',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'Caregiver accounts are for trusted people who support someone else with tasks, routines, reminders, and progress. You will only see information that has been shared through a confirmed support relationship.',
          ),
          const SizedBox(height: 16),
          const Text(
            'This screen should appear once. After confirmation, caregiver accounts open the caregiver dashboard directly.',
          ),
          if (_errorText != null) ...<Widget>[
            const SizedBox(height: 16),
            Text(
              _errorText!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : _confirmCaregiverMode,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_rounded),
            label: Text(_saving ? 'Confirming...' : 'Confirm and continue'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _saving ? null : () => context.go('/login'),
            child: const Text('Back to login'),
          ),
        ],
      ),
    );
  }
}
