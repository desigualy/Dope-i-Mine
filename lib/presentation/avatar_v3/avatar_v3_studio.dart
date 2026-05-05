import 'package:flutter/material.dart';

import '../../domain/avatar_v3/avatar_v3_profile.dart';
import 'avatar_v3_controls.dart';
import 'avatar_v3_preview_card.dart';
import 'avatar_v3_reference_upload_panel.dart';

class AvatarV3Studio extends StatefulWidget {
  const AvatarV3Studio({
    super.key,
    required this.initialProfile,
    required this.onSaved,
  });

  final AvatarV3Profile initialProfile;
  final ValueChanged<AvatarV3Profile> onSaved;

  @override
  State<AvatarV3Studio> createState() => _AvatarV3StudioState();
}

class _AvatarV3StudioState extends State<AvatarV3Studio> {
  late AvatarV3Profile profile;

  @override
  void initState() {
    super.initState();
    profile = widget.initialProfile;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey<String>('avatar-v3-studio'),
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        AvatarV3PreviewCard(profile: profile),
        const SizedBox(height: 16),
        AvatarV3Controls(
          profile: profile,
          onChanged: (next) => setState(() => profile = next),
        ),
        const SizedBox(height: 16),
        AvatarV3ReferenceUploadPanel(
          profile: profile,
          onChanged: (next) => setState(() => profile = next),
        ),
        const SizedBox(height: 16),
        FilledButton(
          key: const ValueKey<String>('avatar-v3-save-button'),
          onPressed: () => widget.onSaved(profile),
          child: const Text('Save Avatar V3'),
        ),
      ],
    );
  }
}
