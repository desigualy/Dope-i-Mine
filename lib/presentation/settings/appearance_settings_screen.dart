import 'package:flutter/material.dart';
import '../../core/widgets/primary_scaffold.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() => _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  Color _selectedColor = Colors.cyan;
  String _selectedIcon = 'Classic';
  bool _dyslexicFont = false;
  double _uiScale = 1.0;

  final List<Color> _accentColors = [
    Colors.cyan,
    Colors.deepPurple,
    Colors.greenAccent,
    Colors.pinkAccent,
    Colors.orangeAccent,
  ];

  final List<String> _appIcons = [
    'Classic',
    'Dark Mode',
    'Minimalist',
    'Pride',
    'Neon',
  ];

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Theming & Appearance',
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Make the app truly yours with custom colors, fonts, and scaling.',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Accent Color',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 12,
              children: _accentColors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedColor = color);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == color ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'App Icon',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedIcon,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.app_shortcut_rounded),
              ),
              items: _appIcons.map((String iconName) {
                return DropdownMenuItem<String>(
                  value: iconName,
                  child: Text(iconName),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => _selectedIcon = newValue);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          SwitchListTile(
            title: const Text('Dyslexia-Friendly Font'),
            subtitle: const Text('Switch the app to OpenDyslexic for better readability.'),
            value: _dyslexicFont,
            secondary: const Icon(Icons.font_download_rounded),
            onChanged: (val) {
              setState(() => _dyslexicFont = val);
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'UI Scaling',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Slider(
            value: _uiScale,
            min: 0.8,
            max: 1.5,
            divisions: 7,
            label: '${(_uiScale * 100).round()}%',
            onChanged: (val) {
              setState(() => _uiScale = val);
            },
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Appearance settings saved.')),
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
