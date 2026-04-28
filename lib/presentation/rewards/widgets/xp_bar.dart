import 'package:flutter/material.dart';

class XPBar extends StatelessWidget {
  const XPBar({
    super.key,
    required this.level,
    required this.progress,
    this.height = 12,
  });

  final int level;
  final double progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Level $level',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.cyan,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[Colors.cyan, Colors.purpleAccent],
                ),
                borderRadius: BorderRadius.circular(height / 2),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
