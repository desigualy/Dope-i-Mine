import 'package:flutter/material.dart';
import '../../core/widgets/primary_scaffold.dart';

class AvatarTweaksScreen extends StatefulWidget {
  const AvatarTweaksScreen({super.key});

  @override
  State<AvatarTweaksScreen> createState() => _AvatarTweaksScreenState();
}

class _AvatarTweaksScreenState extends State<AvatarTweaksScreen> {
  String _renderQuality = 'high';
  bool _showIdleAnimations = true;
  bool _mirrorExpressions = true;
  double _avatarScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Avatar & Companion Tweaks',
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Fine-tune your avatar rendering and companion behaviour.',
            ),
          ),

          // Render Quality
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Render Quality',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          RadioListTile<String>(
            title: const Text('High Fidelity'),
            subtitle: const Text(
              'Best graphics – full lighting, shadows, and particle effects.',
            ),
            secondary: const Icon(Icons.hd_rounded),
            value: 'high',
            groupValue: _renderQuality,
            onChanged: (val) {
              setState(() => _renderQuality = val!);
            },
          ),
          RadioListTile<String>(
            title: const Text('Balanced'),
            subtitle: const Text(
              'Good visuals with moderate battery usage.',
            ),
            secondary: const Icon(Icons.tune_rounded),
            value: 'balanced',
            groupValue: _renderQuality,
            onChanged: (val) {
              setState(() => _renderQuality = val!);
            },
          ),
          RadioListTile<String>(
            title: const Text('Performance'),
            subtitle: const Text(
              'Simplified graphics for better battery life and smoother scrolling.',
            ),
            secondary: const Icon(Icons.speed_rounded),
            value: 'performance',
            groupValue: _renderQuality,
            onChanged: (val) {
              setState(() => _renderQuality = val!);
            },
          ),

          const Divider(),

          // Companion Behaviour
          SwitchListTile(
            title: const Text('Idle Animations'),
            subtitle: const Text(
              'Let your companion fidget, yawn, and look around when idle.',
            ),
            value: _showIdleAnimations,
            secondary: const Icon(Icons.accessibility_new_rounded),
            onChanged: (val) {
              setState(() => _showIdleAnimations = val);
            },
          ),
          SwitchListTile(
            title: const Text('Mirror Expressions'),
            subtitle: const Text(
              'Your companion mirrors your mood based on app activity.',
            ),
            value: _mirrorExpressions,
            secondary: const Icon(Icons.face_rounded),
            onChanged: (val) {
              setState(() => _mirrorExpressions = val);
            },
          ),

          const Divider(),

          // Avatar Scale
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Icon(Icons.photo_size_select_large_rounded),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Avatar Display Size',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${(_avatarScale * 100).round()}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Slider(
            value: _avatarScale,
            min: 0.5,
            max: 1.5,
            divisions: 10,
            label: '${(_avatarScale * 100).round()}%',
            onChanged: (val) {
              setState(() => _avatarScale = val);
            },
          ),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Avatar settings saved.')),
                );
              },
              child: const Text('Save Changes'),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
