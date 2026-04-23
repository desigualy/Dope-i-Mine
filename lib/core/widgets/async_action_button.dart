import 'package:flutter/material.dart';

class AsyncActionButton extends StatelessWidget {
  const AsyncActionButton({super.key, required this.label, required this.loading, required this.onPressed});
  final String label; final bool loading; final VoidCallback? onPressed;
  @override Widget build(BuildContext context) => SizedBox(width: double.infinity, child: ElevatedButton(onPressed: loading ? null : onPressed, child: loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text(label)));
}
