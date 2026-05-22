import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccessibilityShortcutsCard extends StatelessWidget {
  const AccessibilityShortcutsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Accessibility', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Quick access to sensory and voice settings.'),
            const SizedBox(height: 8),
            Row(children: [
              TextButton(onPressed: () => context.go('/settings'), child: const Text('Sensory settings')),
              const SizedBox(width: 8),
              TextButton(onPressed: () => context.go('/settings/voice'), child: const Text('Voice settings')),
            ])
          ],
        ),
      ),
    );
  }
}
