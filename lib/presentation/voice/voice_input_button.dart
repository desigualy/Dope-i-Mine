import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/voice/voice_settings_model.dart';
import 'voice_io_controller.dart';

class VoiceInputButton extends ConsumerStatefulWidget {
  const VoiceInputButton({
    super.key,
    required this.onTextChanged,
    this.onFinalText,
    this.settings,
    this.localeId,
    this.tooltip = 'Speak',
    this.size = 48,
  });

  final ValueChanged<String> onTextChanged;
  final ValueChanged<String>? onFinalText;
  final VoiceSettingsModel? settings;
  final String? localeId;
  final String tooltip;
  final double size;

  @override
  ConsumerState<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends ConsumerState<VoiceInputButton> {
  String? _lastErrorMessage;

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      voiceIoControllerProvider,
      (_, next) => _onControllerChanged(next),
    );
  }

  void _onControllerChanged(VoiceIoController controller) {
    if (!mounted) return;

    final error = controller.state.errorMessage;
    if (error != null && error != _lastErrorMessage) {
      _lastErrorMessage = error;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(voiceIoControllerProvider);

    final state = controller.state;
    final listening = state.isListening;

    return Tooltip(
      message: listening ? 'Stop listening' : widget.tooltip,
      child: GestureDetector(
        onLongPress: listening ? controller.cancelListening : null,
        child: SizedBox.square(
          dimension: widget.size,
          child: IconButton.filledTonal(
            onPressed: state.inputStatus == VoiceInputStatus.initializing
                ? null
                : () async {
                    if (listening) {
                      await controller.stopListening();
                    } else {
                      await controller.startListening(
                        localeId: widget.localeId,
                        onTextChanged: widget.onTextChanged,
                        onFinalText: widget.onFinalText,
                      );
                    }
                  },
            icon: Icon(listening ? Icons.mic : Icons.mic_none),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
