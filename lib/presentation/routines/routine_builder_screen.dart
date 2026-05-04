import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/user_facing_error_mapper.dart';
import '../../core/validators/routine_validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/primary_scaffold.dart';
import '../../data/repositories/routine_templates.dart';
import '../../domain/routines/routine_model.dart';
import '../../domain/routines/routine_step_model.dart';
import '../../providers.dart';
import 'routine_controller.dart';

class RoutineBuilderScreen extends ConsumerStatefulWidget {
  const RoutineBuilderScreen({super.key, this.editing = false});

  final bool editing;

  @override
  ConsumerState<RoutineBuilderScreen> createState() =>
      _RoutineBuilderScreenState();
}

class _RoutineBuilderScreenState extends ConsumerState<RoutineBuilderScreen> {
  final _titleController = TextEditingController();
  final _ageBandController = TextEditingController(text: 'adult');
  final List<TextEditingController> _stepControllers = <TextEditingController>[];
  String? _errorText;
  bool _saving = false;
  bool _loadedEditSteps = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrateInitialState());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ageBandController.dispose();
    for (final controller in _stepControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _hydrateInitialState() async {
    final template = ref.read(routineDraftTemplateProvider);
    if (!widget.editing && template != null) {
      _applyTemplate(template);
      ref.read(routineDraftTemplateProvider.notifier).state = null;
      return;
    }

    if (widget.editing) {
      final routine = ref.read(selectedRoutineProvider);
      if (routine == null) return;
      _titleController.text = routine.title;
      _ageBandController.text = routine.ageBand;
      var steps = ref.read(selectedRoutineStepsProvider);
      if (steps.isEmpty && !_loadedEditSteps) {
        _loadedEditSteps = true;
        try {
          steps = await ref
              .read(routineControllerProvider.notifier)
              .loadSteps(routine.id);
          ref.read(selectedRoutineStepsProvider.notifier).state = steps;
        } catch (_) {
          steps = const <RoutineStepModel>[];
        }
      }
      _replaceStepControllers(steps.map((step) => step.stepText).toList());
      return;
    }

    if (_stepControllers.isEmpty) {
      setState(() => _stepControllers.add(TextEditingController()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedRoutine = ref.watch(selectedRoutineProvider);
    final canEdit = !widget.editing || selectedRoutine != null;

    return PrimaryScaffold(
      title: widget.editing ? 'Edit routine' : 'Build routine',
      actions: <Widget>[
        if (!widget.editing)
          TextButton(
            onPressed: _saving ? null : _showTemplatePicker,
            child: const Text('Templates'),
          ),
      ],
      child: canEdit
          ? ListView(
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
                  controller: _ageBandController,
                  hintText: 'Age band, e.g. child, teen, adult, all',
                ),
                const SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Steps',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addStep,
                      icon: const Icon(Icons.add),
                      label: const Text('Add step'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._stepControllers.asMap().entries.map(
                      (entry) => _StepEditorTile(
                        index: entry.key,
                        controller: entry.value,
                        canMoveUp: entry.key > 0,
                        canMoveDown: entry.key < _stepControllers.length - 1,
                        canDelete: _stepControllers.length > 1,
                        onMoveUp: () => _moveStep(entry.key, -1),
                        onMoveDown: () => _moveStep(entry.key, 1),
                        onDelete: () => _removeStep(entry.key),
                      ),
                    ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_saving ? 'Saving...' : 'Save routine'),
                ),
              ],
            )
          : const Center(
              child: Text('No routine selected. Go back and choose a routine.'),
            ),
    );
  }

  void _addStep() {
    setState(() => _stepControllers.add(TextEditingController()));
  }

  void _removeStep(int index) {
    if (_stepControllers.length <= 1) return;
    final removed = _stepControllers.removeAt(index);
    removed.dispose();
    setState(() {});
  }

  void _moveStep(int index, int delta) {
    final newIndex = index + delta;
    if (newIndex < 0 || newIndex >= _stepControllers.length) return;
    final controller = _stepControllers.removeAt(index);
    _stepControllers.insert(newIndex, controller);
    setState(() {});
  }

  void _replaceStepControllers(List<String> steps) {
    for (final controller in _stepControllers) {
      controller.dispose();
    }
    _stepControllers
      ..clear()
      ..addAll(
        (steps.isEmpty ? <String>[''] : steps)
            .map((step) => TextEditingController(text: step)),
      );
    if (mounted) setState(() {});
  }

  void _applyTemplate(RoutineTemplate template) {
    _titleController.text = template.title;
    _ageBandController.text = template.ageBand;
    _replaceStepControllers(template.steps);
  }

  Future<void> _showTemplatePicker() async {
    final template = await showModalBottomSheet<RoutineTemplate>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Start from template',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
            ),
            ...RoutineTemplateLibrary.all.map(
              (template) => ListTile(
                title: Text(template.title),
                subtitle: Text('${template.steps.length} steps • ${template.category}'),
                onTap: () => Navigator.pop(sheetContext, template),
              ),
            ),
          ],
        ),
      ),
    );
    if (template != null) _applyTemplate(template);
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _errorText = null;
    });

    try {
      final title = _titleController.text.trim();
      final ageBand = _ageBandController.text.trim().isEmpty
          ? 'adult'
          : _ageBandController.text.trim();
      final steps = _stepControllers
          .map((controller) => controller.text.trim())
          .where((step) => step.isNotEmpty)
          .toList();

      validateRoutineTitle(title);
      validateRoutineSteps(steps);

      final authUser = ref.read(authRepositoryProvider).getCurrentUser();
      if (authUser == null) throw Exception('Not authenticated');

      if (widget.editing) {
        final routine = ref.read(selectedRoutineProvider);
        if (routine == null) throw Exception('No routine selected');
        await ref.read(routineControllerProvider.notifier).update(
              userId: authUser.id,
              routineId: routine.id,
              title: title,
              ageBand: ageBand,
              steps: steps,
            );
        final updated = RoutineModel(
          id: routine.id,
          title: title,
          ageBand: ageBand,
          category: routine.category,
          modeTarget: routine.modeTarget,
        );
        ref.read(selectedRoutineProvider.notifier).state = updated;
        final freshSteps = await ref
            .read(routineControllerProvider.notifier)
            .loadSteps(routine.id);
        ref.read(selectedRoutineStepsProvider.notifier).state = freshSteps;
        if (mounted) context.go('/routines/detail');
      } else {
        final routine = await ref.read(routineControllerProvider.notifier).create(
              userId: authUser.id,
              title: title,
              ageBand: ageBand,
              steps: steps,
            );
        ref.read(selectedRoutineProvider.notifier).state = routine;
        final freshSteps = await ref
            .read(routineControllerProvider.notifier)
            .loadSteps(routine.id);
        ref.read(selectedRoutineStepsProvider.notifier).state = freshSteps;
        if (mounted) context.go('/routines/detail');
      }
    } catch (error) {
      if (mounted) setState(() => _errorText = mapToUserFacingError(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _StepEditorTile extends StatelessWidget {
  const _StepEditorTile({
    required this.index,
    required this.controller,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.canDelete,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
  });

  final int index;
  final TextEditingController controller;
  final bool canMoveUp;
  final bool canMoveDown;
  final bool canDelete;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: CircleAvatar(radius: 14, child: Text('${index + 1}')),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                controller: controller,
                hintText: 'Step ${index + 1}',
                maxLines: 2,
              ),
            ),
            const SizedBox(width: 4),
            Column(
              children: <Widget>[
                IconButton(
                  tooltip: 'Move up',
                  onPressed: canMoveUp ? onMoveUp : null,
                  icon: const Icon(Icons.keyboard_arrow_up),
                ),
                IconButton(
                  tooltip: 'Move down',
                  onPressed: canMoveDown ? onMoveDown : null,
                  icon: const Icon(Icons.keyboard_arrow_down),
                ),
                IconButton(
                  tooltip: 'Delete step',
                  onPressed: canDelete ? onDelete : null,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
