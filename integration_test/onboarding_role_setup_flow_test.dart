import 'package:dope_i_mine/presentation/onboarding/onboarding_role_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('role setup renders first-run role choices', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      const ProviderScope(
          child: MaterialApp(home: OnboardingRoleSetupScreen())),
    );

    expect(find.text('I am using this for myself'), findsOneWidget);
    expect(find.text('I support someone else'), findsOneWidget);
    expect(find.text('Someone supports me'), findsOneWidget);
    expect(find.text('Both apply to me'), findsOneWidget);
  });
}
