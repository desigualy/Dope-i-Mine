import 'package:flutter/material.dart';

import '../../../core/widgets/primary_scaffold.dart';

class OnboardingPageScaffold extends StatelessWidget {
  const OnboardingPageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.onBack,
    this.onNext,
    this.nextLabel = 'Next',
    this.nextEnabled = true,
    this.bottom,
  });

  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String nextLabel;
  final bool nextEnabled;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: title,
      leading: onBack == null
          ? null
          : IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back',
            ),
      child: Column(
        children: <Widget>[
          Expanded(child: child),
          const SizedBox(height: 16),
          bottom ??
              _OnboardingBottomActions(
                onBack: onBack,
                onNext: onNext,
                nextLabel: nextLabel,
                nextEnabled: nextEnabled,
              ),
        ],
      ),
    );
  }
}

class _OnboardingBottomActions extends StatelessWidget {
  const _OnboardingBottomActions({
    required this.onBack,
    required this.onNext,
    required this.nextLabel,
    required this.nextEnabled,
  });

  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String nextLabel;
  final bool nextEnabled;

  @override
  Widget build(BuildContext context) {
    final hasBack = onBack != null;
    return Row(
      children: <Widget>[
        if (hasBack) ...<Widget>[
          Expanded(
            child: OutlinedButton(
              onPressed: onBack,
              child: const Text('Back'),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: FilledButton(
            onPressed: (!nextEnabled || onNext == null) ? null : onNext,
            child: Text(nextLabel),
          ),
        ),
      ],
    );
  }
}
