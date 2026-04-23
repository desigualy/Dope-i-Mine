import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dope_i_mine/app/app.dart';

void main() {
  testWidgets('app boots', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: DopeIMineApp(),
      ),
    );

    expect(find.text('Overwhelmed by tasks? Meet Dope-i.'), findsOneWidget);
  });
}
