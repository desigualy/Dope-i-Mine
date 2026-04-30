import 'package:flutter/material.dart';

import '../../domain/avatar/avatar_quality_validator.dart';

class AvatarQualityIssuesPanel extends StatelessWidget {
  const AvatarQualityIssuesPanel({
    super.key,
    required this.result,
  });

  final AvatarQualityResult result;

  @override
  Widget build(BuildContext context) {
    if (result.issues.isEmpty) {
      return Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Text('Avatar prompt passed quality checks.'),
        ),
      );
    }

    return Card(
      color: result.hasBlockers
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              result.hasBlockers
                  ? 'Avatar quality blockers'
                  : 'Avatar quality notes',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            for (final issue in result.issues)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('• ${issue.message}'),
              ),
          ],
        ),
      ),
    );
  }
}
