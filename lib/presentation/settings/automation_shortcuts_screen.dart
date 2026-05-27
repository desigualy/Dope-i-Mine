import 'package:flutter/material.dart';
import '../../core/widgets/primary_scaffold.dart';

class AutomationShortcutsScreen extends StatefulWidget {
  const AutomationShortcutsScreen({super.key});

  @override
  State<AutomationShortcutsScreen> createState() =>
      _AutomationShortcutsScreenState();
}

class _AutomationShortcutsScreenState extends State<AutomationShortcutsScreen> {
  bool _siriShortcuts = false;
  bool _googleAssistant = false;
  bool _alexaSkill = false;

  // Widget config
  String _widgetStyle = 'progress';
  bool _widgetDarkMode = true;

  // Webhooks
  final List<_WebhookEntry> _webhooks = [];
  final TextEditingController _webhookUrlCtrl = TextEditingController();
  final TextEditingController _webhookLabelCtrl = TextEditingController();

  @override
  void dispose() {
    _webhookUrlCtrl.dispose();
    _webhookLabelCtrl.dispose();
    super.dispose();
  }

  void _addWebhook() {
    final url = _webhookUrlCtrl.text.trim();
    final label = _webhookLabelCtrl.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _webhooks.add(_WebhookEntry(
        label: label.isEmpty ? 'Webhook ${_webhooks.length + 1}' : label,
        url: url,
      ));
      _webhookUrlCtrl.clear();
      _webhookLabelCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Widgets, Automation & Shortcuts',
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Set up voice assistants, home screen widgets, and power-user automations.',
            ),
          ),

          // Voice Assistants
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Voice Assistant Integration',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Siri Shortcuts'),
            subtitle: const Text(
              '"Hey Siri, start my morning routine" – enable voice commands.',
            ),
            value: _siriShortcuts,
            secondary: const Icon(Icons.mic_rounded),
            onChanged: (val) {
              setState(() => _siriShortcuts = val);
            },
          ),
          SwitchListTile(
            title: const Text('Google Assistant'),
            subtitle: const Text(
              '"OK Google, log my task" – enable Google voice commands.',
            ),
            value: _googleAssistant,
            secondary: const Icon(Icons.assistant_rounded),
            onChanged: (val) {
              setState(() => _googleAssistant = val);
            },
          ),
          SwitchListTile(
            title: const Text('Amazon Alexa'),
            subtitle: const Text(
              '"Alexa, what\'s my next routine?" – enable Alexa skill.',
            ),
            value: _alexaSkill,
            secondary: const Icon(Icons.speaker_rounded),
            onChanged: (val) {
              setState(() => _alexaSkill = val);
            },
          ),

          const Divider(),

          // Home Screen Widget
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Home Screen Widget',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          RadioListTile<String>(
            title: const Text('Daily Progress Ring'),
            subtitle: const Text('Show today\'s completion percentage.'),
            value: 'progress',
            groupValue: _widgetStyle,
            secondary: const Icon(Icons.donut_large_rounded),
            onChanged: (val) {
              setState(() => _widgetStyle = val!);
            },
          ),
          RadioListTile<String>(
            title: const Text('Next Routine Countdown'),
            subtitle: const Text('Show time until your next scheduled routine.'),
            value: 'countdown',
            groupValue: _widgetStyle,
            secondary: const Icon(Icons.timer_rounded),
            onChanged: (val) {
              setState(() => _widgetStyle = val!);
            },
          ),
          RadioListTile<String>(
            title: const Text('Streak & XP Badge'),
            subtitle: const Text('Show your current streak and level.'),
            value: 'streak',
            groupValue: _widgetStyle,
            secondary: const Icon(Icons.local_fire_department_rounded),
            onChanged: (val) {
              setState(() => _widgetStyle = val!);
            },
          ),
          SwitchListTile(
            title: const Text('Widget Dark Mode'),
            subtitle: const Text('Force dark appearance for the home widget.'),
            value: _widgetDarkMode,
            secondary: const Icon(Icons.dark_mode_rounded),
            onChanged: (val) {
              setState(() => _widgetDarkMode = val);
            },
          ),

          const Divider(),

          // Custom Webhooks
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Custom Webhooks (Power Users)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Fire a POST request to a custom URL whenever you complete a routine. '
              'Great for IFTTT, Zapier, or your own server.',
            ),
          ),
          const SizedBox(height: 12),
          // Existing webhooks
          if (_webhooks.isNotEmpty)
            ...List.generate(_webhooks.length, (i) {
              final wh = _webhooks[i];
              return ListTile(
                title: Text(wh.label),
                subtitle: Text(
                  wh.url,
                  overflow: TextOverflow.ellipsis,
                ),
                leading: const Icon(Icons.webhook_rounded),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () {
                    setState(() => _webhooks.removeAt(i));
                  },
                ),
              );
            }),
          // Add new webhook
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                TextField(
                  controller: _webhookLabelCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Label (optional)',
                    hintText: 'e.g. "Notion Logger"',
                    prefixIcon: Icon(Icons.label_outline_rounded),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _webhookUrlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Webhook URL',
                    hintText: 'https://hooks.example.com/...',
                    prefixIcon: Icon(Icons.link_rounded),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: _addWebhook,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Webhook'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Automation settings saved.'),
                  ),
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

class _WebhookEntry {
  final String label;
  final String url;
  const _WebhookEntry({required this.label, required this.url});
}
