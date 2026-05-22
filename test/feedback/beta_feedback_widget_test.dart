import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dope_i_mine/presentation/feedback/beta_feedback_screen.dart';

void main() {
  testWidgets('Beta feedback screen shows form', (tester) async {
    await tester.pumpWidget(MaterialApp(home: BetaFeedbackScreen()));

    expect(find.text('Beta feedback'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Submit feedback'), findsOneWidget);
  });
}
