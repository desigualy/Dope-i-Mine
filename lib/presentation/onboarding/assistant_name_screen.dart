import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_text_field.dart';
import 'onboarding_controller.dart';
import 'widgets/onboarding_step_scaffold.dart';

class AssistantNameScreen extends ConsumerStatefulWidget {
  const AssistantNameScreen({super.key, this.returnToSummary = false});

  final bool returnToSummary;

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
    return OnboardingStepScaffold(
      title: 'Name your assistant',
      stepNumber: 4,
      totalSteps: 9,
      onBack: () => context.go(
        widget.returnToSummary
            ? '/onboarding/summary'
            : '/onboarding/age-band',
      ),
      onNext: () {
        ref.read(onboardingControllerProvider.notifier).setAssistantDisplayName(
              _controller.text.trim().isEmpty ? 'Dope-i' : _controller.text.trim(),
            );
        context.go(
          widget.returnToSummary
              ? '/onboarding/summary'
              : '/onboarding/mode',
        );
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Keep Dope-i or choose your own nickname.'),
            const SizedBox(height: 12),
            AppTextField(controller: _controller, hintText: 'Dope-i'),
          ],
        ),
      ),
    );
  }
}
