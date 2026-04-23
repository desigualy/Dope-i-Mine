import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_scaffold.dart';
import '../../providers.dart';

class CaregiverAssignRoutineScreen extends ConsumerStatefulWidget {
  const CaregiverAssignRoutineScreen({super.key});

  @override
  ConsumerState<CaregiverAssignRoutineScreen> createState() =>
      _CaregiverAssignRoutineScreenState();
}

class _CaregiverAssignRoutineScreenState
    extends ConsumerState<CaregiverAssignRoutineScreen> {
  final _targetUserIdController = TextEditingController();
  final _routineIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Assign routine',
      child: Column(
        children: <Widget>[
          AppTextField(
            controller: _targetUserIdController,
            hintText: 'Target user ID',
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _routineIdController,
            hintText: 'Routine ID',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final authUser = ref.read(authRepositoryProvider).getCurrentUser();
              if (authUser == null) return;
              await ref.read(caregiverAssignmentsRepositoryProvider).assignRoutine(
                    caregiverUserId: authUser.id,
                    targetUserId: _targetUserIdController.text.trim(),
                    routineId: _routineIdController.text.trim(),
                  );
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }
}
