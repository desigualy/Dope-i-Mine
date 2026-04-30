import 'package:flutter/material.dart';

class MinimumVersionToggle extends StatelessWidget {
  const MinimumVersionToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Show minimum version'),
      value: value,
      onChanged: onChanged,
    );
  }
}
