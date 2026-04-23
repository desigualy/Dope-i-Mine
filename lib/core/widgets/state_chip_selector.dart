import 'package:flutter/material.dart';

class StateChipSelector<T> extends StatelessWidget {
  const StateChipSelector({super.key, required this.label, required this.values, required this.selected, required this.getLabel, required this.onSelected});
  final String label; final List<T> values; final T selected; final String Function(T value) getLabel; final ValueChanged<T> onSelected;
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(label, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 8), Wrap(spacing: 8, runSpacing: 8, children: values.map((value) => ChoiceChip(label: Text(getLabel(value)), selected: value == selected, onSelected: (_) => onSelected(value))).toList())]);
}
