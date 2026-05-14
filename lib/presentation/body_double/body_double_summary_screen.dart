import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_back_button.dart';
import 'body_double_controller.dart';

class BodyDoubleSummaryScreen extends ConsumerWidget {
  const BodyDoubleSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(bodyDoubleControllerProvider).lastSummary;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Session summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Body double complete',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              summary?.summary ?? 'You gave yourself support. That counts.',
              key: const ValueKey<String>('body-double-summary-text'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 24),
            if (ref.watch(bodyDoubleControllerProvider).dopeiSummaryNote != null)
              Card(
                color: Colors.teal.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.teal.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: Colors.teal),
                      const SizedBox(height: 12),
                      Text(
                        ref.watch(bodyDoubleControllerProvider).dopeiSummaryNote!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.stars_rounded, color: Colors.amber),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Consistency reward: +5 Reliability Score for completing this session!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => context.go('/tasks/breakdown'),
              child: const Text('Return to tasks'),
            ),
          ],
        ),
      ),
    );
  }
}
