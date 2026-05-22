import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// onboarding_controller is not used directly here.

class OnboardingFirstTaskPromptScreen extends ConsumerStatefulWidget {
  const OnboardingFirstTaskPromptScreen({super.key});

  @override
  ConsumerState<OnboardingFirstTaskPromptScreen> createState() => _State();
}

class _State extends ConsumerState<OnboardingFirstTaskPromptScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create your first task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Text('Want to start with one small thing?'),
          const SizedBox(height: 12),
          TextField(controller: _controller, decoration: const InputDecoration(labelText: 'Task title')),
          const SizedBox(height: 12),
          Row(children: [
            TextButton(onPressed: () => context.pop(), child: const Text('Back')),
            const Spacer(),
            TextButton(onPressed: () => context.go('/'), child: const Text('Skip and go home')),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _saveAndFinish, child: const Text('Save and finish')),
          ])
        ]),
      ),
    );
  }

  Future<void> _saveAndFinish() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved task locally')));
    }
    if (mounted) context.go('/');
  }
}
