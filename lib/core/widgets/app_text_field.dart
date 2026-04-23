import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({super.key, required this.controller, required this.hintText, this.maxLines = 1});
  final TextEditingController controller; final String hintText; final int maxLines;
  @override Widget build(BuildContext context) => TextField(controller: controller, maxLines: maxLines, decoration: InputDecoration(hintText: hintText, border: const OutlineInputBorder()));
}
