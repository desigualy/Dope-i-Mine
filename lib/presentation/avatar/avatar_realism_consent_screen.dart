import 'package:flutter/material.dart';

class AvatarRealismConsentScreen extends StatelessWidget {
  const AvatarRealismConsentScreen({
    super.key,
    required this.onContinue,
    required this.onUseIllustrated,
    required this.onUsePrivateAvatar,
  });

  final VoidCallback onContinue;
  final VoidCallback onUseIllustrated;
  final VoidCallback onUsePrivateAvatar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realistic avatar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Icon(
            Icons.verified_user_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 18),
          Text(
            'Before we create a realistic avatar',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'Your avatar is generated from choices, not from face recognition.',
          ),
          const SizedBox(height: 8),
          const Text(
            'No real photo is required.',
          ),
          const SizedBox(height: 8),
          const Text(
            'You can delete the generated avatar at any time.',
          ),
          const SizedBox(height: 8),
          const Text(
            'If you prefer privacy, you can use an illustrated or abstract avatar instead.',
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onContinue,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Continue'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onUseIllustrated,
            child: const Text('Use illustrated avatar'),
          ),
          TextButton(
            onPressed: onUsePrivateAvatar,
            child: const Text('Use private abstract avatar'),
          ),
        ],
      ),
    );
  }
}
