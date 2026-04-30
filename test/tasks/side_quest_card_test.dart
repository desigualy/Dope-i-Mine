import 'package:dope_i_mine/presentation/tasks/widgets/side_quest_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SideQuestCard shows countdown and completes from button',
      (tester) async {
    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SideQuestCard(
            title: 'Take 3 slow breaths',
            rewardText: '+10 XP',
            contextLabel: 'Overwhelm boost',
            countdownEndsAt: DateTime.now().add(const Duration(minutes: 2)),
            onComplete: () => completed = true,
          ),
        ),
      ),
    );

    expect(find.text('Take 3 slow breaths'), findsOneWidget);
    expect(find.textContaining('Bonus countdown'), findsOneWidget);
    expect(find.text('Overwhelm boost'), findsOneWidget);

    await tester.tap(find.text('DONE'));
    await tester.pump();

    expect(completed, isTrue);
  });
}