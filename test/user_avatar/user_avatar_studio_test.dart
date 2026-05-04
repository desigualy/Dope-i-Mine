import 'package:dope_i_mine/presentation/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home page exposes avatar entry point and core actions',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Hi there!'), findsOneWidget);
    expect(find.text('Ready to tackle your day?'), findsOneWidget);
    expect(find.text('My avatar'), findsOneWidget);
    expect(find.text('New task'), findsOneWidget);
  });

  testWidgets('home avatar card remains available for editing flow',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('My avatar'), findsOneWidget);
    expect(find.byIcon(Icons.face_retouching_natural_rounded), findsWidgets);
  });
}
