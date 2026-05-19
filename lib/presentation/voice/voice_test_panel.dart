import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/voice/voice_profile_model.dart';
import 'voice_controller.dart';
import 'voice_io_controller.dart';

class VoiceTestPanel extends ConsumerStatefulWidget {
  const VoiceTestPanel({
    super.key,
    this.previewProfile,
    this.previewSpeechRate,
  });

  final VoiceProfileModel? previewProfile;
  final double? previewSpeechRate;

  @override
  ConsumerState<VoiceTestPanel> createState() => _VoiceTestPanelState();
}

class _VoiceTestPanelState extends ConsumerState<VoiceTestPanel> {
  final TextEditingController _ttsTextController = TextEditingController(
    text: 'Hello! This is a test of the text to speech engine on Dope-i-Mine.',
  );

  @override
  void dispose() {
    _ttsTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voiceIo = ref.watch(voiceIoControllerProvider);
    final voiceController = ref.watch(voiceControllerProvider);

    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.record_voice_over_rounded, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Voice & Speech Diagnostics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 32),
            
            // TTS section
            Text(
              'Text-to-Speech (TTS) Test',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ttsTextController,
              decoration: const InputDecoration(
                labelText: 'Test Speech Text',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final text = _ttsTextController.text.trim();
                      if (text.isNotEmpty) {
                        voiceController.speakStep(
                          text,
                          previewProfile: widget.previewProfile,
                          previewSpeechRate: widget.previewSpeechRate,
                        );
                      }
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Speak Test Text'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () => voiceController.stopSpeaking(),
                  icon: const Icon(Icons.stop_rounded),
                  tooltip: 'Stop Speaking',
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // STT section
            Text(
              'Speech-to-Text (STT) Test',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: ${voiceIo.state.inputStatus.name.toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: voiceIo.state.isListening ? Colors.green : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Recognized Text:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    voiceIo.state.recognizedText.isEmpty
                        ? '(No speech detected yet)'
                        : voiceIo.state.recognizedText,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (voiceIo.state.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Error: ${voiceIo.state.errorMessage}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: voiceIo.state.isListening
                          ? Colors.red.shade100
                          : null,
                    ),
                    onPressed: () {
                      if (voiceIo.state.isListening) {
                        voiceIo.stopListening();
                      } else {
                        voiceIo.startListening(
                          onTextChanged: (_) {},
                        );
                      }
                    },
                    icon: Icon(
                      voiceIo.state.isListening
                          ? Icons.mic_off_rounded
                          : Icons.mic_rounded,
                    ),
                    label: Text(
                      voiceIo.state.isListening
                          ? 'Stop Listening'
                          : 'Listen / Test STT',
                    ),
                  ),
                ),
                if (voiceIo.state.isListening) ...[
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () => voiceIo.cancelListening(),
                    icon: const Icon(Icons.cancel_rounded),
                    tooltip: 'Cancel Listening',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
