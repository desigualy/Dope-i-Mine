import 'package:flutter/material.dart';

/// Shared scaffold for the onboarding “wizard” experience.
///
/// Provides:
/// - consistent padding
/// - step progress indicator
/// - AppBar back button
/// - Back/Next bottom navigation (optional)
class OnboardingStepScaffold extends StatelessWidget {
  const OnboardingStepScaffold({
    super.key,
    required this.title,
    required this.stepNumber,
    required this.totalSteps,
    required this.child,
    this.onBack,
    this.onNext,
    this.nextLabel = 'Next',
    this.nextEnabled = true,
    this.bottom,
  });

  /// AppBar title.
  final String title;

  /// 1-based step number shown to the user.
  final int stepNumber;

  final int totalSteps;

  /// Main content area (should not include bottom navigation buttons).
  final Widget child;

  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String nextLabel;
  final bool nextEnabled;

  /// Optional override for bottom area (e.g. async “Finish” button on summary).
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final clampedStep = stepNumber.clamp(1, totalSteps);
    final progress = totalSteps <= 0 ? 0.0 : clampedStep / totalSteps;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: onBack == null
            ? null
            : IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
              ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Step $clampedStep of $totalSteps',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: child),
              const SizedBox(height: 16),
              bottom ?? _DefaultBottomNav(
                onBack: onBack,
                onNext: onNext,
                nextLabel: nextLabel,
                nextEnabled: nextEnabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DefaultBottomNav extends StatelessWidget {
  const _DefaultBottomNav({
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
