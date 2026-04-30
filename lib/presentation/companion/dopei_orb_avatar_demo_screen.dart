import 'package:flutter/material.dart';

import '../../core/widgets/primary_scaffold.dart';
import '../../domain/companion/dopei_mood.dart';
import 'dopei_orb_avatar.dart';

class DopeiOrbDemoScreen extends StatefulWidget {
  const DopeiOrbDemoScreen({super.key});

  @override
  State<DopeiOrbDemoScreen> createState() => _DopeiOrbDemoScreenState();
}

class _DopeiOrbDemoScreenState extends State<DopeiOrbDemoScreen> {
  DopeiMood _mood = DopeiMood.neutral;
  bool _reducedMotion = false;

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Dope-i neon mascot',
      child: Column(
        children: <Widget>[
          const SizedBox(height: 16),
          Center(
            child: DopeiOrbAvatar(
              mood: _mood,
              reducedMotion: _reducedMotion,
              showLabel: true,
              size: 176,
            ),
          ),
          SwitchListTile(
            value: _reducedMotion,
            onChanged: (value) => setState(() => _reducedMotion = value),
            title: const Text('Reduced motion'),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              children: DopeiMood.values.map((mood) {
                return OutlinedButton(
                  onPressed: () => setState(() => _mood = mood),
                  child: Text(mood.label),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
