import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/section_header.dart';
import '../onboarding/widgets/onboarding_step_scaffold.dart';

class DopeIIntroScreen extends StatelessWidget {
  const DopeIIntroScreen({super.key, this.returnToSummary = false});

  final bool returnToSummary;

  @override
  Widget build(BuildContext context) {
    // This screen is always part of onboarding. The legacy PrimaryScaffold
    // import remains for any future non-onboarding entry points.
    final backTarget = returnToSummary ? '/onboarding/summary' : '/';
    final nextTarget =
        returnToSummary ? '/onboarding/summary' : '/branding/pronunciation';

    return OnboardingStepScaffold(
      title: 'Meet Dope-i',
      stepNumber: 1,
      totalSteps: 12,
      onBack: () => context.go(backTarget),
      onNext: () => context.go(nextTarget),
      nextLabel: returnToSummary ? 'Done' : 'Continue',
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionHeader(
            title: 'Dope-i (Dopy), your Dope-i-Mine assistant',
            subtitle: 'Rewarding the chase of progress, one task at a time.',
          ),
          SizedBox(height: 16),
          Text('I break big tasks into wins you can feel immediately.'),
        ],
      ),
    );
  }
}
