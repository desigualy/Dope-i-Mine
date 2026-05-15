import 'package:flutter/material.dart';

class AvatarV4ReferenceImagePanel extends StatelessWidget {
  const AvatarV4ReferenceImagePanel({
    super.key = const Key('avatar-v4-reference-image-panel'),
    this.isOnline = false,
    this.userId,
    this.referenceImageUrl,
    this.serviceLabel,
    this.onImportReference,
    this.onClearReference,
  });

  final bool isOnline;
  final String? userId;
  final String? referenceImageUrl;
  final String? serviceLabel;
  final VoidCallback? onImportReference;
  final VoidCallback? onClearReference;

  bool get _hasReferenceImage =>
      referenceImageUrl != null && referenceImageUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveServiceLabel =
        serviceLabel?.trim().isNotEmpty == true ? serviceLabel!.trim() : 'Avatar V4 reference service';

    return Semantics(
      label: 'Avatar V4 reference image panel',
      container: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            key: const Key('avatar-v4-reference-image-panel-content'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.image_search_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Reference image',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  _ConnectionBadge(isOnline: isOnline),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _hasReferenceImage
                    ? 'A reference image is linked for this avatar session.'
                    : isOnline
                        ? 'Add a reference image to guide the Avatar V4 customizer.'
                        : 'Offline mode: reference images are unavailable until the device reconnects.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                effectiveServiceLabel,
                key: const Key('avatar-v4-reference-service-label'),
                style: theme.textTheme.bodySmall,
              ),
              if (userId != null && userId!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Profile: ${userId!.trim()}',
                  key: const Key('avatar-v4-reference-user-label'),
                  style: theme.textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 16),
              if (_hasReferenceImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    referenceImageUrl!,
                    key: const Key('avatar-v4-reference-image-preview'),
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _ReferenceFallback(
                        message: 'Reference image could not be loaded.',
                      );
                    },
                  ),
                )
              else
                const _ReferenceFallback(
                  message: 'No reference image selected.',
                ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    key: const Key('avatar-v4-reference-import-button'),
                    onPressed: isOnline ? onImportReference : null,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text('Add reference'),
                  ),
                  OutlinedButton.icon(
                    key: const Key('avatar-v4-reference-clear-button'),
                    onPressed: _hasReferenceImage ? onClearReference : null,
                    icon: const Icon(Icons.close),
                    label: const Text('Clear'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionBadge extends StatelessWidget {
  const _ConnectionBadge({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      key: Key(
        isOnline
            ? 'avatar-v4-reference-online-badge'
            : 'avatar-v4-reference-offline-badge',
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          isOnline ? 'Online' : 'Offline',
          style: theme.textTheme.labelSmall,
        ),
      ),
    );
  }
}

class _ReferenceFallback extends StatelessWidget {
  const _ReferenceFallback({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: const Key('avatar-v4-reference-empty-state'),
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}