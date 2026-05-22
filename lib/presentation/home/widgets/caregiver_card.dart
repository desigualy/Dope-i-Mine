import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CaregiverCard extends StatelessWidget {
  const CaregiverCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Caregiver', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('No pending caregiver items.'),
            const SizedBox(height: 8),
            TextButton(onPressed: () => context.go('/caregiver'), child: const Text('View caregivers')),
          ],
        ),
      ),
    );
  }
}
