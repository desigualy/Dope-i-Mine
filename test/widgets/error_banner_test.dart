
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dope_i_mine/core/widgets/error_banner.dart';

void main() {
  testWidgets('error banner renders supplied message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ErrorBanner(message: 'Something went wrong'),
        ),
      ),
    );

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });
}
