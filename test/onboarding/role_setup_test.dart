import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dope_i_mine/presentation/onboarding/onboarding_role_setup_screen.dart';

void main() {
  testWidgets('Role setup renders options', (tester) async {
    await tester.pumpWidget(MaterialApp(home: OnboardingRoleSetupScreen()));

    expect(find.text('Who is using the app?'), findsOneWidget);
    expect(find.text('I’m using this for myself'), findsOneWidget);
    expect(find.text('I support someone else'), findsOneWidget);
    expect(find.text('Someone supports me'), findsOneWidget);
    expect(find.text('Both apply to me'), findsOneWidget);
  });
}
