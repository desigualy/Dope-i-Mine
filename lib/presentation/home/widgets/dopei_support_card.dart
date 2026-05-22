import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dope_i_mine/presentation/core/widgets/dopei_guide.dart';
import 'package:dope_i_mine/presentation/overwhelm/overwhelm_support_sheet.dart';

class DopeiSupportCard extends ConsumerWidget {
  const DopeiSupportCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DopeiGuide(
              text: 'I can help you get started — tap me to hear a calm suggestion.',
              mood: DopeiMood.calm,
              size: 64,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (_) => const OverwhelmSupportSheet(),
                    );
                  },
                  child: const Text('Feeling overwhelmed?'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => context.go('/body-double/start'),
                  child: const Text('Start body double'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
