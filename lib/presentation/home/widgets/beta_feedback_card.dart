import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class BetaFeedbackCard extends ConsumerWidget {
  const BetaFeedbackCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Beta feedback', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Report bugs or accessibility issues to help us improve.'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => context.push('/feedback/beta'),
              child: const Text('Report'),
            ),
          ],
        ),
      ),
    );
  }
}
