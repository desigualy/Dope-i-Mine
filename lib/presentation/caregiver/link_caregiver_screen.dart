import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_scaffold.dart';
import '../../providers.dart';
import 'caregiver_controller.dart';

class LinkCaregiverScreen extends ConsumerStatefulWidget {
  const LinkCaregiverScreen({super.key});

  @override
  ConsumerState<LinkCaregiverScreen> createState() =>
      _LinkCaregiverScreenState();
}

class _LinkCaregiverScreenState extends ConsumerState<LinkCaregiverScreen> {
  final _caregiverIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Link caregiver',
      child: Column(
        children: <Widget>[
          AppTextField(
            controller: _caregiverIdController,
            hintText: 'Caregiver user ID',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final authUser = ref.read(authRepositoryProvider).getCurrentUser();
              if (authUser == null) return;
              await ref.read(caregiverControllerProvider.notifier).link(
                    primaryUserId: authUser.id,
                    caregiverUserId: _caregiverIdController.text.trim(),
                    permissionLevel: 'read',
                  );
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Link'),
          ),
        ],
      ),
    );
  }
}
