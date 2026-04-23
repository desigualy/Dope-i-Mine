import 'package:flutter/material.dart';

class SideQuestCard extends StatelessWidget {
  const SideQuestCard({
    super.key,
    required this.title,
    required this.rewardText,
  });

  final String title;
  final String rewardText;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(rewardText),
      ),
    );
  }
}
