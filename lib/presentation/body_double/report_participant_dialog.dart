import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'body_double_controller.dart';

class ReportParticipantDialog extends ConsumerStatefulWidget {
  final String participantUserId;
  final String sessionId;
  final String displayName;

  const ReportParticipantDialog({
    super.key,
    required this.participantUserId,
    required this.sessionId,
    required this.displayName,
  });

  @override
  ConsumerState<ReportParticipantDialog> createState() => _ReportParticipantDialogState();
}

class _ReportParticipantDialogState extends ConsumerState<ReportParticipantDialog> {
  String _reason = 'Inappropriate behavior';
  final _detailsController = TextEditingController();
  bool _submitting = false;

  final List<String> _reasons = [
    'Inappropriate behavior',
    'Abusive language',
    'Inappropriate background',
    'Spamming',
    'Underage (for adult session)',
    'Adult (for minor session)',
    'Other',
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Report ${widget.displayName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your report is anonymous and helps keep our community safe.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _reason,
              decoration: const InputDecoration(labelText: 'Reason'),
              items: _reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (val) => setState(() => _reason = val!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _detailsController,
              decoration: const InputDecoration(
                labelText: 'Details (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: _submitting ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Submit Report'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await ref.read(bodyDoubleControllerProvider.notifier).reportParticipant(
        _reason,
        _detailsController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted. Thank you for keeping Dope-i-Mine safe.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit report. Please try again.')),
        );
      }
    }
  }
}
