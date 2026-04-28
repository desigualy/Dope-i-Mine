import 'package:flutter/material.dart';

class DopeiAvatar extends StatelessWidget {
  const DopeiAvatar({
    super.key,
    required this.mood,
    this.size = 120,
  });

  final String mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: Image.asset(
        'assets/avatar/dopei/$mood.png',
        key: ValueKey(mood),
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) {
          // Fallback if image doesn't exist yet
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.face,
              color: Colors.cyan,
              size: size * 0.6,
            ),
          );
        },
      ),
    );
  }
}

class FloatingDopeiAvatar extends StatefulWidget {
  const FloatingDopeiAvatar({
    super.key,
    required this.mood,
    this.size = 120,
  });

  final String mood;
  final double size;

  @override
  State<FloatingDopeiAvatar> createState() => _FloatingDopeiAvatarState();
}

class _FloatingDopeiAvatarState extends State<FloatingDopeiAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _float = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _float.value),
          child: child,
        );
      },
      child: DopeiAvatar(
        mood: widget.mood,
        size: widget.size,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
