import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationsSummaryCard extends StatelessWidget {
  const NotificationsSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('No unread notifications.'),
            const SizedBox(height: 8),
            TextButton(onPressed: () => context.go('/notifications'), child: const Text('View notifications')),
          ],
        ),
      ),
    );
  }
}
