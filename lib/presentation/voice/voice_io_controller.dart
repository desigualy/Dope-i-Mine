import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

final voiceIoControllerProvider =
    ChangeNotifierProvider<VoiceIoController>((ref) {
  final controller = VoiceIoController();
  ref.onDispose(controller.dispose);
  return controller;
});

enum VoiceInputStatus {
  idle,
  initializing,
  listening,
  stopped,
  unavailable,
  error,
}

@immutable
class VoiceIoState {
  const VoiceIoState({
    this.inputStatus = VoiceInputStatus.idle,
    this.recognizedText = '',
    this.errorMessage,
    this.available = false,
    this.initialized = false,
  });

  final VoiceInputStatus inputStatus;
  final String recognizedText;
  final String? errorMessage;
  final bool available;
  final bool initialized;

  bool get isListening => inputStatus == VoiceInputStatus.listening;

  VoiceIoState copyWith({
    VoiceInputStatus? inputStatus,
    String? recognizedText,
    String? errorMessage,
    bool clearError = false,
    bool? available,
    bool? initialized,
  }) {
    return VoiceIoState(
      inputStatus: inputStatus ?? this.inputStatus,
      recognizedText: recognizedText ?? this.recognizedText,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      available: available ?? this.available,
      initialized: initialized ?? this.initialized,
    );
  }
}

class VoiceIoController extends ChangeNotifier {
  VoiceIoController({SpeechToText? speech}) : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;
  VoiceIoState _state = const VoiceIoState();
  bool _disposed = false;

  VoiceIoState get state => _state;

  Future<bool> initialize() async {
    if (_state.initialized) return _state.available;

    _setState(
      _state.copyWith(
        inputStatus: VoiceInputStatus.initializing,
        clearError: true,
      ),
    );

    try {
      final available = await _speech.initialize(
        onError: _handleSpeechError,
        onStatus: _handleSpeechStatus,
      );

      _setState(
        _state.copyWith(
          inputStatus:
              available ? VoiceInputStatus.idle : VoiceInputStatus.unavailable,
          available: available,
          initialized: true,
          errorMessage: available
              ? null
              : 'Speech recognition is not available on this device.',
        ),
      );
      return available;
    } catch (_) {
      _setState(
        _state.copyWith(
          inputStatus: VoiceInputStatus.error,
          available: false,
          initialized: true,
          errorMessage:
              'Speech recognition could not start. Check microphone permissions.',
        ),
      );
      return false;
    }
  }

  Future<void> startListening({
    String? localeId,
    required ValueChanged<String> onTextChanged,
    ValueChanged<String>? onFinalText,
  }) async {
    if (_state.isListening) return;

    final available = await initialize();
    if (!available) return;

    try {
      _setState(
        _state.copyWith(
          inputStatus: VoiceInputStatus.listening,
          recognizedText: '',
          clearError: true,
        ),
      );

      await _speech.listen(
        localeId: localeId,
        listenMode: ListenMode.confirmation,
        partialResults: true,
        onResult: (SpeechRecognitionResult result) {
          final text = result.recognizedWords.trim();
          _setState(_state.copyWith(recognizedText: text));
          onTextChanged(text);
          if (result.finalResult && onFinalText != null) {
            onFinalText(text);
          }
        },
      );
    } catch (_) {
      _setState(
        _state.copyWith(
          inputStatus: VoiceInputStatus.error,
          errorMessage: 'Could not listen. Check microphone permissions.',
        ),
      );
    }
  }

  Future<void> stopListening() async {
    try {
      await _speech.stop();
    } finally {
      _setState(_state.copyWith(inputStatus: VoiceInputStatus.stopped));
    }
  }

  Future<void> cancelListening() async {
    try {
      await _speech.cancel();
    } finally {
      _setState(_state.copyWith(inputStatus: VoiceInputStatus.stopped));
    }
  }

  void _handleSpeechError(SpeechRecognitionError error) {
    _setState(
      _state.copyWith(
        inputStatus: VoiceInputStatus.error,
        errorMessage: error.errorMsg.isEmpty
            ? 'Speech recognition stopped unexpectedly.'
            : error.errorMsg,
      ),
    );
  }

  void _handleSpeechStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      if (_state.inputStatus == VoiceInputStatus.listening) {
        _setState(_state.copyWith(inputStatus: VoiceInputStatus.stopped));
      }
    }
  }

  void _setState(VoiceIoState next) {
    if (_disposed) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _speech.cancel();
    super.dispose();
  }
}
