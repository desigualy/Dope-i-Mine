import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/avatar_v4_reference_image_service.dart';
import '../domain/avatar_v4_reference_image_upload.dart';
import '../domain/avatar_v4_sync_failure.dart';

class AvatarReferenceImagePanel extends StatefulWidget {
  const AvatarReferenceImagePanel({
    super.key,
    required this.userId,
    required this.isOnline,
    this.service,
    this.imagePicker,
    this.onUploaded,
  });

  final String? userId;
  final bool isOnline;
  final AvatarV4ReferenceImageService? service;
  final ImagePicker? imagePicker;
  final ValueChanged<AvatarV4ReferenceImageUpload>? onUploaded;

  @override
  State<AvatarReferenceImagePanel> createState() =>
      _AvatarReferenceImagePanelState();
}

class _AvatarReferenceImagePanelState extends State<AvatarReferenceImagePanel> {
  bool _consented = false;
  bool _busy = false;
  String? _message;
  bool _isError = false;

  bool get _canUpload =>
      widget.isOnline &&
      widget.userId != null &&
      widget.userId!.trim().isNotEmpty &&
      widget.service != null &&
      _consented &&
      !_busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      key: const ValueKey<String>('avatar-v4-reference-image-panel'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Reference photo',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload a photo only if you want the avatar system to use it as a reference. The app stores the consent record and storage path, not a silent hidden profile.',
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              key: const ValueKey<String>('avatar-v4-reference-consent'),
              contentPadding: EdgeInsets.zero,
              value: _consented,
              onChanged: _busy
                  ? null
                  : (value) {
                      setState(() {
                        _consented = value == true;
                      });
                    },
              title: const Text('I consent to upload this reference image.'),
              subtitle: const Text(
                'Avatar changes and uploads require an online connection.',
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              key: const ValueKey<String>('avatar-v4-reference-upload-button'),
              onPressed: _canUpload ? _pickAndUpload : null,
              icon: _busy
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Upload reference photo'),
            ),
            if (!widget.isOnline) ...<Widget>[
              const SizedBox(height: 8),
              const Text(
                'Connect to the internet to upload or change avatar reference photos.',
                key: ValueKey<String>('avatar-v4-reference-offline-message'),
              ),
            ],
            if (widget.service == null) ...<Widget>[
              const SizedBox(height: 8),
              const Text(
                'Upload service is not connected yet.',
                key: ValueKey<String>('avatar-v4-reference-service-missing'),
              ),
            ],
            if (_message != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                _message!,
                key: const ValueKey<String>('avatar-v4-reference-upload-message'),
                style: TextStyle(
                  color: _isError
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUpload() async {
    final service = widget.service;
    final userId = widget.userId;

    if (service == null || userId == null || userId.trim().isEmpty) return;

    setState(() {
      _busy = true;
      _message = null;
      _isError = false;
    });

    try {
      final picker = widget.imagePicker ?? ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 92,
      );

      if (file == null) {
        setState(() {
          _message = 'No reference image selected.';
          _isError = false;
        });
        return;
      }

      final upload = await service.uploadPickedReferenceImageOnlineRequired(
        userId: userId,
        file: file,
        isOnline: widget.isOnline,
      );

      widget.onUploaded?.call(upload);

      setState(() {
        _message = 'Reference photo uploaded.';
        _isError = false;
      });
    } on AvatarV4SyncFailure catch (error) {
      setState(() {
        _message = error.message;
        _isError = true;
      });
    } catch (_) {
      setState(() {
        _message = 'Reference photo upload failed.';
        _isError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }
}
