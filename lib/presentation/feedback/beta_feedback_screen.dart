import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';

class BetaFeedbackScreen extends ConsumerStatefulWidget {
  const BetaFeedbackScreen({super.key});

  @override
  ConsumerState<BetaFeedbackScreen> createState() => _BetaFeedbackScreenState();
}

class _BetaFeedbackScreenState extends ConsumerState<BetaFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'bug';
  String _message = '';
  bool _saving = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _saving = true);
    final entry = {
      'id': DateTime.now().toUtc().toIso8601String(),
      'type': _type,
      'message': _message,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      await ref.read(localFeedbackStoreProvider).saveFeedback(entry);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved feedback locally.')));
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save feedback.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beta feedback')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'bug', child: Text('Bug')),
                  DropdownMenuItem(value: 'confusing', child: Text('Confusing screen')),
                  DropdownMenuItem(value: 'accessibility', child: Text('Accessibility issue')),
                  DropdownMenuItem(value: 'body_double', child: Text('Body double issue')),
                  DropdownMenuItem(value: 'caregiver', child: Text('Caregiver issue')),
                  DropdownMenuItem(value: 'voice', child: Text('Voice issue')),
                  DropdownMenuItem(value: 'notification', child: Text('Notification issue')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'bug'),
                decoration: const InputDecoration(labelText: 'Feedback type'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Message', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().length < 5) ? 'Please enter a short message' : null,
                onSaved: (v) => _message = v?.trim() ?? '',
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _saving ? null : _submit,
                child: _saving ? const CircularProgressIndicator() : const Text('Submit feedback'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
