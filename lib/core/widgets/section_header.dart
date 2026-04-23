import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.subtitle});
  final String title; final String? subtitle;
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(title, style: Theme.of(context).textTheme.headlineSmall), if (subtitle != null) ...<Widget>[const SizedBox(height: 8), Text(subtitle!)] ]);
}
