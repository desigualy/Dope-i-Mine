import 'package:flutter/material.dart';

import 'widgets/avatar_v4_reference_image_panel.dart';

class AvatarV4CustomizerScreen extends StatelessWidget {
  const AvatarV4CustomizerScreen({
    super.key,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar V4 Customizer'),
      ),
      body: SafeArea(
        child: ListView(
          key: const Key('avatar-v4-customizer-scroll-view'),
          padding: const EdgeInsets.all(16),
          children: [
            AvatarV4ReferenceImagePanel(
              isOnline: isOnline,
              userId: userId,
              referenceImageUrl: referenceImageUrl,
              serviceLabel: serviceLabel,
              onImportReference: onImportReference,
              onClearReference: onClearReference,
            ),
            const SizedBox(height: 16),
            const _AvatarCustomizerBody(),
          ],
        ),
      ),
    );
  }
}

class _AvatarCustomizerBody extends StatelessWidget {
  const _AvatarCustomizerBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      key: const Key('avatar-v4-customizer-body'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Avatar customisation controls',
          style: theme.textTheme.titleMedium,
        ),
      ),
    );
  }
}