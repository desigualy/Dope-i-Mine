import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/permissions_service.dart';
import '../../core/services/speech_to_text_service.dart';
import '../../core/services/text_to_speech_service.dart';
import 'onboarding_controller.dart';
import 'widgets/onboarding_step_scaffold.dart';

final _permissionsServiceProvider = Provider<PermissionsService>((ref) {
  return PermissionsService();
});

final _sttServiceProvider = Provider<SpeechToTextService>((ref) {
  return SpeechToTextService();
});

final _ttsServiceProvider = Provider<TextToSpeechService>((ref) {
  return TextToSpeechService();
});

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key, this.returnToSummary = false});

  final bool returnToSummary;

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  bool _checking = false;
  String? _status;

  Future<void> _runChecks() async {
    setState(() {
      _checking = true;
      _status = null;
    });
    try {
      final permissions = ref.read(_permissionsServiceProvider);
      final stt = ref.read(_sttServiceProvider);
      final tts = ref.read(_ttsServiceProvider);

      final micOk = await permissions.requestMicrophone();
      final notifOk = await permissions.requestNotifications();
      final sttOk = await stt.initialize();
      await tts.initialize();

      ref.read(onboardingControllerProvider.notifier).setMicrophoneEnabled(micOk);
      ref.read(onboardingControllerProvider.notifier).setNotificationsEnabled(notifOk);

      setState(() {
        _status = 'Notifications: ${notifOk ? 'OK' : 'Unavailable'} · '
            'Microphone: ${micOk ? 'OK' : 'Unavailable'} · '
            'STT: ${sttOk ? 'OK' : 'Unavailable'} · TTS: OK';
      });
    } catch (e) {
      setState(() => _status = 'Permission/device checks failed: $e');
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
      title: 'Permissions & device checks',
      stepNumber: 8,
      totalSteps: 12,
      onBack: () => context.go(
        widget.returnToSummary ? '/onboarding/summary' : '/onboarding/accessibility',
      ),
      onNext: () => context.go(
        widget.returnToSummary ? '/onboarding/summary' : '/onboarding/voice-setup',
      ),
      nextLabel: widget.returnToSummary ? 'Done' : 'Next',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'We’ll check what your device supports. You can change these later in Settings.',
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _checking ? null : _runChecks,
            child: Text(_checking ? 'Checking…' : 'Run checks'),
          ),
          const SizedBox(height: 12),
          if (_status != null) Text(_status!),
          const SizedBox(height: 12),
          const Text('Preferences (saved locally for this onboarding run):'),
          const SizedBox(height: 8),
          SwitchListTile(
            value: ref.watch(onboardingControllerProvider).notificationsEnabled,
            onChanged: (value) => ref
                .read(onboardingControllerProvider.notifier)
                .setNotificationsEnabled(value),
            title: const Text('Enable notifications / reminders'),
          ),
          SwitchListTile(
            value: ref.watch(onboardingControllerProvider).microphoneEnabled,
            onChanged: (value) => ref
                .read(onboardingControllerProvider.notifier)
                .setMicrophoneEnabled(value),
            title: const Text('Enable microphone / speech-to-text'),
          ),
          const SizedBox(height: 12),
          const Text(
            'Note: real permission prompts can be added via permission_handler. '
            'Right now this is best-effort and relies on platform configuration.',
          ),
        ],
      ),
    );
  }
}
