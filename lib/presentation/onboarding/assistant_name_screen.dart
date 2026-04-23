import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_scaffold.dart';
import 'onboarding_controller.dart';

class AssistantNameScreen extends ConsumerStatefulWidget {
  const AssistantNameScreen({super.key});

  @override
  ConsumerState<AssistantNameScreen> createState() => _AssistantNameScreenState();
}

class _AssistantNameScreenState extends ConsumerState<AssistantNameScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(onboardingControllerProvider).assistantDisplayName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Name your assistant',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Keep Dope-i or choose your own nickname.'),
          const SizedBox(height: 12),
          AppTextField(controller: _controller, hintText: 'Dope-i'),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(onboardingControllerProvider.notifier).setAssistantDisplayName(
                    _controller.text.trim().isEmpty ? 'Dope-i' : _controller.text.trim());
                context.go('/onboarding/mode');
              },
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}
