import 'package:flutter/material.dart';

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message});
  final String message;
  @override Widget build(BuildContext context) => Material(color: Theme.of(context).colorScheme.errorContainer, borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.all(12), child: Row(children: <Widget>[const Icon(Icons.error_outline), const SizedBox(width: 8), Expanded(child: Text(message))])));
}
