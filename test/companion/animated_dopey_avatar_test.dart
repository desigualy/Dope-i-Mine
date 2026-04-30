import 'package:dope_i_mine/domain/companion/dopei_mood.dart';
import 'package:dope_i_mine/presentation/companion/animated_dopey_avatar.dart';
import 'package:dope_i_mine/presentation/companion/dopei_orb_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a static asset when reduced motion is enabled',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedDopeyAvatar(
            mood: DopeiMood.calm,
            reducedMotion: true,
          ),
        ),
      ),
    );

    expect(_findDopeiMascotPaint(), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('animated-dopey-switcher')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('animated-dopey-motion-calm')),
      findsNothing,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('uses the animated shell when motion is allowed', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedDopeyAvatar(
            mood: DopeiMood.happy,
          ),
        ),
      ),
    );

    expect(_findDopeiMascotPaint(), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('animated-dopey-switcher')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('animated-dopey-motion-happy')),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Finder _findDopeiMascotPaint() {
  return find.byWidgetPredicate(
    (widget) => widget is CustomPaint && widget.painter is DopeiOrbPainter,
  );
}
