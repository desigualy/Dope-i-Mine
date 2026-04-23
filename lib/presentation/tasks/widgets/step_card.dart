import 'package:flutter/material.dart';

import '../../../domain/tasks/task_step_model.dart';

class StepCard extends StatelessWidget {
  const StepCard({
    super.key,
    required this.step,
    this.onBreakDownMore,
    this.onComplete,
  });

  final TaskStepModel step;
  final VoidCallback? onBreakDownMore;
  final Future<void> Function()? onComplete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(step.text),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                ElevatedButton(
                  onPressed: onComplete,
                  child: const Text('Done'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onBreakDownMore,
                  child: const Text('Break down more'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
