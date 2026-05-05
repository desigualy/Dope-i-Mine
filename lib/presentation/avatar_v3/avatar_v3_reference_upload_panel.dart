import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/avatar_v3/avatar_v3_profile.dart';
import '../../domain/avatar_v3/avatar_v3_reference_image.dart';

class AvatarV3ReferenceUploadPanel extends StatelessWidget {
  const AvatarV3ReferenceUploadPanel({
    super.key,
    required this.profile,
    required this.onChanged,
    ImagePicker? picker,
  }) : _picker = picker;

  final AvatarV3Profile profile;
  final ValueChanged<AvatarV3Profile> onChanged;
  final ImagePicker? _picker;

  @override
  Widget build(BuildContext context) {
    final reference = profile.referenceImage;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Reference image',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              reference == null
                  ? 'Optional. Stored as reference metadata for user-guided matching.'
                  : 'Reference attached: ${reference.localPath}',
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const ValueKey<String>('avatar-v3-reference-upload-button'),
              onPressed: () async {
                final picker = _picker ?? ImagePicker();
                final picked = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 90,
                );
                if (picked == null) return;
                onChanged(
                  profile.copyWith(
                    referenceImage: AvatarV3ReferenceImage(
                      localPath: picked.path,
                      capturedAt: DateTime.now().toUtc(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.image_outlined),
              label: const Text('Choose reference image'),
            ),
          ],
        ),
      ),
    );
  }
}
