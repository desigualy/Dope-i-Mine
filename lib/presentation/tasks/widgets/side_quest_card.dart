import 'dart:async';

import 'package:flutter/material.dart';

class SideQuestCard extends StatefulWidget {
  const SideQuestCard({
    super.key,
    required this.title,
    required this.rewardText,
    this.onComplete,
    this.isCompleted = false,
    this.countdownEndsAt,
    this.contextLabel,
  });

  final String title;
  final String rewardText;
  final VoidCallback? onComplete;
  final bool isCompleted;
  final DateTime? countdownEndsAt;
  final String? contextLabel;

  @override
  State<SideQuestCard> createState() => _SideQuestCardState();
}

class _SideQuestCardState extends State<SideQuestCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _startCountdown();
  }

  @override
  void didUpdateWidget(covariant SideQuestCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.countdownEndsAt != widget.countdownEndsAt) {
      _startCountdown();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _glowController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    _syncRemaining();
    if (widget.countdownEndsAt == null || widget.isCompleted) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(_syncRemaining);
      if (_remaining == Duration.zero) {
        _timer?.cancel();
      }
    });
  }

  void _syncRemaining() {
    final deadline = widget.countdownEndsAt;
    if (deadline == null) {
      _remaining = Duration.zero;
      return;
    }
    final remaining = deadline.difference(DateTime.now());
    _remaining = remaining.isNegative ? Duration.zero : remaining;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final countdownEnded = widget.countdownEndsAt != null &&
        _remaining == Duration.zero &&
        !widget.isCompleted;

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: widget.isCompleted
                    ? Colors.transparent
                    : primary.withOpacity(
                        countdownEnded
                            ? 0.05
                            : 0.1 + (_glowController.value * 0.1),
                      ),
                blurRadius: 8 + (_glowController.value * 4),
                spreadRadius: 1 + (_glowController.value * 1),
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: widget.isCompleted
                    ? Colors.transparent
                    : primary.withOpacity(
                        countdownEnded
                            ? 0.16
                            : 0.2 + (_glowController.value * 0.2),
                      ),
                width: 1.5,
              ),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration:
                      widget.isCompleted ? TextDecoration.lineThrough : null,
                  color: widget.isCompleted ? Colors.grey : null,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.rewardText,
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    if (widget.contextLabel != null) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(
                        widget.contextLabel!,
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                    if (widget.countdownEndsAt != null) ...<Widget>[
                      const SizedBox(height: 6),
                      _CountdownPill(
                        remaining: _remaining,
                        ended: countdownEnded,
                      ),
                    ],
                  ],
                ),
              ),
              trailing: widget.isCompleted
                  ? const Icon(Icons.check_circle,
                      color: Colors.green, size: 32)
                  : ElevatedButton(
                      onPressed: widget.onComplete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                      child: const Text(
                        'DONE',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, letterSpacing: 1.2),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _CountdownPill extends StatelessWidget {
  const _CountdownPill({required this.remaining, required this.ended});

  final Duration remaining;
  final bool ended;

  @override
  Widget build(BuildContext context) {
    final color = ended ? Colors.deepOrange : Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.timer_outlined, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            ended ? 'Final chance' : 'Bonus countdown ${_format(remaining)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
