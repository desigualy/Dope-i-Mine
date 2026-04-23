import 'package:flutter/material.dart';

import 'color_tokens.dart';
import 'spacing_tokens.dart';
import 'text_tokens.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ColorTokens.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: ColorTokens.backgroundLight,
      textTheme: TextTokens.textTheme,
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.all(SpacingTokens.md),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ColorTokens.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: ColorTokens.backgroundDark,
      textTheme: TextTokens.textTheme,
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.all(SpacingTokens.md),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
