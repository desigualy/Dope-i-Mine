import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BodyDoubleInvitesCard extends StatelessWidget {
  const BodyDoubleInvitesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Body-double', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('No new invites.'),
            const SizedBox(height: 8),
            TextButton(onPressed: () => context.go('/body-double'), child: const Text('Open body-double')),
          ],
        ),
      ),
    );
  }
}
