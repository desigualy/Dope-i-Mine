import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  void showSimpleSnack(String text) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(text)));
  }
}
