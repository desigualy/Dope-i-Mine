import 'package:flutter/material.dart';
import '../../core/widgets/primary_scaffold.dart';

class AiPersonalityScreen extends StatefulWidget {
  const AiPersonalityScreen({super.key});

  @override
  State<AiPersonalityScreen> createState() => _AiPersonalityScreenState();
}

class _AiPersonalityScreenState extends State<AiPersonalityScreen> {
  bool _advancedModel = false;
  String _archetype = 'Professional Assistant';
  double _verbosity = 0.5;
  double _tone = 0.5;

  final List<String> _archetypes = [
    'Professional Assistant',
    'Gentle Enforcer',
    'Sarcastic Best Friend',
    'Strict Coach',
  ];

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'AI & Personality',
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Customize how your companion thinks and speaks.',
            ),
          ),
          SwitchListTile(
            title: const Text('Advanced Reasoning Model'),
            subtitle: const Text('Use a more capable AI model (may be slower and use more data).'),
            value: _advancedModel,
            secondary: const Icon(Icons.psychology_rounded),
            onChanged: (val) {
              setState(() => _advancedModel = val);
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Personality Archetype',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<String>(
              value: _archetype,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_pin_rounded),
              ),
              items: _archetypes.map((String archetype) {
                return DropdownMenuItem<String>(
                  value: archetype,
                  child: Text(archetype),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => _archetype = newValue);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Verbosity (Concise to Chatty)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Slider(
            value: _verbosity,
            onChanged: (val) {
              setState(() => _verbosity = val);
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Tone (Strict to Empathetic)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Slider(
            value: _tone,
            onChanged: (val) {
              setState(() => _tone = val);
            },
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('AI Personality preferences saved.')),
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
