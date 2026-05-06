import 'package:dope_i_mine/presentation/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home page exposes Avatar Engine V4 entry point and core actions',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Hi there!'), findsOneWidget);
    expect(find.text('Ready to tackle your day?'), findsOneWidget);

    expect(
      find.byKey(const ValueKey<String>('home-avatar-v4-rive')),
      findsOneWidget,
    );

    expect(find.text('My avatar'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('New task'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('New task'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('My routines'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('My routines'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('My progress'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('My progress'), findsOneWidget);
  });

  testWidgets('home avatar card remains available for editing flow',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('My avatar'), findsOneWidget);
    expect(find.byIcon(Icons.face_retouching_natural_rounded), findsWidgets);
    expect(
      find.byKey(const ValueKey<String>('home-avatar-v4-rive')),
      findsOneWidget,
    );
  });
}
