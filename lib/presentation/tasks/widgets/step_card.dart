import 'package:flutter/material.dart';

import '../../../domain/tasks/task_step_model.dart';

class StepCard extends StatelessWidget {
  const StepCard({
    super.key,
    required this.step,
    this.onBreakDownMore,
    this.onComplete,
    this.depthIndent = 0,
  });

  final TaskStepModel step;
  final VoidCallback? onBreakDownMore;
  final Future<void> Function()? onComplete;
  final int depthIndent;

  @override
  Widget build(BuildContext context) {
    final isCompleted = step.status == StepStatus.completed;
    final canComplete = onComplete != null && !isCompleted;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(left: depthIndent * 16.0),
      child: Card(
        child: InkWell(
          onTap: canComplete ? () => onComplete?.call() : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Checkbox(
                      value: isCompleted,
                      onChanged: canComplete ? (_) => onComplete?.call() : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            step.text,
                            style: TextStyle(
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isCompleted
                                  ? colorScheme.onSurface.withOpacity(0.55)
                                  : null,
                              fontWeight: step.depthLevel > 1
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                            ),
                          ),
                          if (step.depthLevel > 1) ...<Widget>[
                            const SizedBox(height: 2),
                            Text(
                              'Micro task',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: colorScheme.primary),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    ElevatedButton.icon(
                      onPressed: canComplete ? onComplete : null,
                      icon: Icon(
                        isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                      ),
                      label: const Text('Done'),
                    ),
                    if (onBreakDownMore != null)
                      OutlinedButton.icon(
                        onPressed: onBreakDownMore,
                        icon: const Icon(Icons.account_tree_outlined),
                        label: const Text('Break down more'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
