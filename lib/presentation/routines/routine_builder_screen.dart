import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/user_facing_error_mapper.dart';
import '../../core/validators/routine_validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/primary_scaffold.dart';
import '../../providers.dart';
import 'routine_controller.dart';

class RoutineBuilderScreen extends ConsumerStatefulWidget {
  const RoutineBuilderScreen({super.key});

  @override
  ConsumerState<RoutineBuilderScreen> createState() =>
      _RoutineBuilderScreenState();
}

class _RoutineBuilderScreenState extends ConsumerState<RoutineBuilderScreen> {
  final _titleController = TextEditingController();
  final _step1Controller = TextEditingController();
  final _step2Controller = TextEditingController();
  final _step3Controller = TextEditingController();
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Build routine',
      child: ListView(
        children: <Widget>[
          if (_errorText != null) ...<Widget>[
            ErrorBanner(message: _errorText!),
            const SizedBox(height: 12),
          ],
          AppTextField(
            controller: _titleController,
            hintText: 'Routine title',
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _step1Controller,
            hintText: 'Step 1',
          ),
          const SizedBox(height: 8),
          AppTextField(
            controller: _step2Controller,
            hintText: 'Step 2',
          ),
          const SizedBox(height: 8),
          AppTextField(
            controller: _step3Controller,
            hintText: 'Step 3',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              try {
                final steps = <String>[
                  _step1Controller.text.trim(),
                  _step2Controller.text.trim(),
                  _step3Controller.text.trim(),
                ].where((e) => e.isNotEmpty).toList();

                validateRoutineTitle(_titleController.text);

                final authUser = ref.read(authRepositoryProvider).getCurrentUser();
                if (authUser == null) throw Exception('Not authenticated');

                await ref.read(routineControllerProvider.notifier).create(
                      userId: authUser.id,
                      title: _titleController.text.trim(),
                      ageBand: 'adult',
                      steps: steps,
                    );
                if (mounted) Navigator.pop(context);
              } catch (error) {
                setState(() => _errorText = mapToUserFacingError(error));
              }
            },
            child: const Text('Save routine'),
          ),
        ],
      ),
    );
  }
}
