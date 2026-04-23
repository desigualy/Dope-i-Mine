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
              title: const Text('Make it smaller'),
              onTap: () async {
                await controller.requestRescue();
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Only show first step'),
              onTap: () {
                controller.pauseSafely();
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
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
