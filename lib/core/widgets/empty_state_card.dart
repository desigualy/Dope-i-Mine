import 'package:flutter/material.dart';

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({super.key, required this.title, required this.subtitle});
  final String title; final String subtitle;
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: <Widget>[Text(title, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 8), Text(subtitle, textAlign: TextAlign.center)])));
}
