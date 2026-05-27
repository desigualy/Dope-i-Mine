import 'package:dope_i_mine/presentation/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void useTallViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('home page exposes Avatar Engine V4 entry point and core actions',
      (tester) async {
    useTallViewport(tester);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Hi there!'), findsOneWidget);
    expect(find.text('Ready to tackle your day?'), findsOneWidget);

    expect(
      find.byKey(const ValueKey<String>('home-avatar-v4-rive')),
      findsOneWidget,
    );

    expect(find.text('My avatar'), findsOneWidget);

    expect(find.text('Start from something friendly'), findsOneWidget);

    expect(
      find.text('Choose a template, then remix it until it fits.'),
      findsOneWidget,
    );
  });

  testWidgets('home avatar card remains available for editing flow',
      (tester) async {
    useTallViewport(tester);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('My avatar'), findsOneWidget);
    expect(find.text('My avatar'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('home-avatar-v4-rive')),
      findsOneWidget,
    );
  });
}
