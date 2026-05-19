import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'voice_controller.dart';

class SpeakButton extends ConsumerStatefulWidget {
  const SpeakButton({
    super.key,
    required this.text,
    this.iconSize,
    this.color,
  });

  final String text;
  final double? iconSize;
  final Color? color;

  @override
  ConsumerState<SpeakButton> createState() => _SpeakButtonState();
}

class _SpeakButtonState extends ConsumerState<SpeakButton> {
  bool _isSpeaking = false;

  Future<void> _toggleSpeak() async {
    if (widget.text.trim().isEmpty) return;

    final controller = ref.read(voiceControllerProvider);

    try {
      if (_isSpeaking) {
        await controller.stopSpeaking();
        if (mounted) {
          setState(() {
            _isSpeaking = false;
          });
        }
      } else {
        setState(() {
          _isSpeaking = true;
        });
        await controller.speakStep(widget.text);
        // Automatically reset the speaking icon after some time or on completion if possible.
        // Let's set a simple auto-reset after a duration based on length to keep the UX clean.
        final approxDurationMs = (widget.text.length * 80).clamp(1000, 15000);
        Future<void>.delayed(Duration(milliseconds: approxDurationMs), () {
          if (mounted && _isSpeaking) {
            setState(() {
              _isSpeaking = false;
            });
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return IconButton(
      iconSize: widget.iconSize,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
      icon: Icon(
        _isSpeaking ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
      ),
      onPressed: _toggleSpeak,
      tooltip: _isSpeaking ? 'Stop speaking' : 'Read aloud',
    );
  }

  @override
  void dispose() {
    if (_isSpeaking) {
      try {
        ref.read(voiceControllerProvider).stopSpeaking();
      } catch (_) {}
    }
    super.dispose();
  }
}
