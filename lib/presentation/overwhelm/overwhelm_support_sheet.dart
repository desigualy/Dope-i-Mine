import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'overwhelm_controller.dart';

class OverwhelmSupportSheet extends ConsumerWidget {
  const OverwhelmSupportSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(overwhelmControllerProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.auto_awesome, color: Colors.amber),
              title: const Text('Rescue me (Activate Calm Mode)'),
              subtitle: const Text('Smallest steps, one at a time.'),
              onTap: () {
                controller.activateOverwhelmMode();
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_red_eye_outlined),
              title: const Text('Only show the current step'),
              onTap: () {
                controller.activateOverwhelmMode(); // Use full calm mode for simplicity
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.pause_circle_outline),
              title: const Text('Pause safely'),
              onTap: () {
                controller.pauseSafely();
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
