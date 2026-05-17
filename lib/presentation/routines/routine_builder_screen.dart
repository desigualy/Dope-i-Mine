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
import '../voice/voice_input_button.dart';
import '../voice/voice_controller.dart';
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
  final List<TextEditingController> _stepControllers =
      <TextEditingController>[];
  String? _errorText;
  bool _saving = false;
  bool _loadedEditSteps = false;

  static const List<String> _quickAddSteps = <String>[
    'Drink water',
    'Take one slow breath',
    'Set a 5 minute timer',
    'Put essentials in one place',
    'Celebrate the tiny win',
  ];

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
    final completedStepCount = _stepControllers
        .where((controller) => controller.text.trim().isNotEmpty)
        .length;

    return PrimaryScaffold(
      title: widget.editing ? 'Edit routine' : 'Build routine',
      actions: <Widget>[
        if (!widget.editing)
          TextButton.icon(
            onPressed: _saving ? null : _showTemplatePicker,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('Templates'),
          ),
      ],
      child: canEdit
          ? ListView(
              physics: const BouncingScrollPhysics(),
              children: <Widget>[
                _BuilderHero(
                  editing: widget.editing,
                  stepCount: completedStepCount,
                  onTemplates: _saving ? null : _showTemplatePicker,
                ),
                const SizedBox(height: 16),
                if (_errorText != null) ...<Widget>[
                  ErrorBanner(message: _errorText!),
                  const SizedBox(height: 12),
                ],
                _BuilderCard(
                  icon: Icons.emoji_objects_rounded,
                  title: 'Name the vibe',
                  subtitle:
                      'Give this routine a friendly label so Future You knows what it is for.',
                  child: Column(
                    children: <Widget>[
                      AppTextField(
                        controller: _titleController,
                        hintText: 'e.g. Cosy morning launchpad',
                        suffixIcon: VoiceInputButton(
                          onTextChanged: (text) => _titleController.text = text,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _ageBandController,
                        hintText: 'Age band, e.g. child, teen, adult, all',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _QuickAddCard(
                  suggestions: _quickAddSteps,
                  onSuggestionTap: _addSuggestedStep,
                  onBlankStep: _addStep,
                ),
                const SizedBox(height: 16),
                _StepsHeader(
                  count: _stepControllers.length,
                  onAddStep: _addStep,
                  speakSteps: () {
                    final stepsText = _stepControllers
                        .map((controller) => controller.text.trim())
                        .where((text) => text.isNotEmpty)
                        .toList();
                    final text = stepsText.isEmpty
                        ? "You haven't written any steps yet."
                        : "Your routine steps are: ${stepsText.join(', then ')}.";
                    ref.read(voiceControllerProvider).speakStep(text);
                  },
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 18),
                _SavePanel(
                  saving: _saving,
                  editing: widget.editing,
                  stepCount: completedStepCount,
                  onSave: _save,
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

  void _addSuggestedStep(String text) {
    final emptyIndex = _stepControllers.indexWhere(
      (controller) => controller.text.trim().isEmpty,
    );
    setState(() {
      if (emptyIndex == -1) {
        _stepControllers.add(TextEditingController(text: text));
      } else {
        _stepControllers[emptyIndex].text = text;
      }
    });
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
    final savedTaskTemplates = ref.read(savedTaskRoutineTemplatesProvider);
    final templates = <RoutineTemplate>[
      ...savedTaskTemplates,
      ...RoutineTemplateLibrary.all,
    ];
    final template = await showModalBottomSheet<RoutineTemplate>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => _TemplatePickerSheet(
        templates: templates,
        savedTaskTemplates: savedTaskTemplates,
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
        final routine =
            await ref.read(routineControllerProvider.notifier).create(
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

class _BuilderHero extends StatelessWidget {
  const _BuilderHero({
    required this.editing,
    required this.stepCount,
    required this.onTemplates,
  });

  final bool editing;
  final int stepCount;
  final VoidCallback? onTemplates;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            scheme.primary,
            scheme.tertiary.withOpacity(0.9),
            const Color(0xFFFF8A65),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: scheme.primary.withOpacity(0.24),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -18,
            top: -22,
            child: Icon(Icons.bubble_chart_rounded,
                size: 132, color: Colors.white.withOpacity(0.12)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(0.22)),
                ),
                child: Text(
                  editing ? 'Routine remix mode' : 'Make it feel doable',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                editing
                    ? 'Tune this routine until it fits today.'
                    : 'Build a tiny rhythm that feels kind, clear, and easy to start.',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Use templates, playful quick-adds, and moveable steps. No perfect routine required — just the next friendly version.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      height: 1.35,
                    ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  _HeroPill(
                    icon: Icons.checklist_rtl_rounded,
                    label: '$stepCount ready steps',
                  ),
                  const _HeroPill(
                    icon: Icons.drag_indicator_rounded,
                    label: 'Reorder anytime',
                  ),
                  if (!editing)
                    ActionChip(
                      avatar: const Icon(Icons.auto_awesome_rounded, size: 18),
                      label: const Text('Browse templates'),
                      onPressed: onTemplates,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                          color: scheme.primary, fontWeight: FontWeight.w900),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _BuilderCard extends StatelessWidget {
  const _BuilderCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest.withOpacity(0.42),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: BorderSide(color: scheme.outlineVariant.withOpacity(0.65)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: scheme.primary.withOpacity(0.12),
                  foregroundColor: scheme.primary,
                  child: Icon(icon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 3),
                      Text(subtitle,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _QuickAddCard extends StatelessWidget {
  const _QuickAddCard({
    required this.suggestions,
    required this.onSuggestionTap,
    required this.onBlankStep,
  });

  final List<String> suggestions;
  final ValueChanged<String> onSuggestionTap;
  final VoidCallback onBlankStep;

  @override
  Widget build(BuildContext context) {
    return _BuilderCard(
      icon: Icons.bolt_rounded,
      title: 'Quick-add sparks',
      subtitle: 'Tap a helper step, then edit it to sound like you.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions
                .map(
                  (step) => ActionChip(
                    avatar: const Icon(Icons.add_rounded, size: 18),
                    label: Text(step),
                    onPressed: () => onSuggestionTap(step),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onBlankStep,
            icon: const Icon(Icons.add_task_rounded),
            label: const Text('Add my own step'),
          ),
        ],
      ),
    );
  }
}

class _StepsHeader extends ConsumerWidget {
  const _StepsHeader({required this.count, required this.onAddStep, required this.speakSteps});

  final int count;
  final VoidCallback onAddStep;
  final VoidCallback speakSteps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Text(
                    'Your routine path',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Read all steps aloud',
                    icon: const Icon(Icons.volume_up_rounded, size: 20),
                    onPressed: speakSteps,
                  ),
                ],
              ),
              Text(
                '$count editable ${count == 1 ? 'step' : 'steps'}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: onAddStep,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add step'),
        ),
      ],
    );
  }
}

class _SavePanel extends StatelessWidget {
  const _SavePanel({
    required this.saving,
    required this.editing,
    required this.stepCount,
    required this.onSave,
  });

  final bool saving;
  final bool editing;
  final int stepCount;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: scheme.primary.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            stepCount == 0
                ? 'Add at least one step to save your routine.'
                : '$stepCount ${stepCount == 1 ? 'step' : 'steps'} ready to become a repeatable win.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: saving ? null : onSave,
            icon: saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.favorite_rounded),
            label: Text(saving
                ? 'Saving...'
                : editing
                    ? 'Save routine glow-up'
                    : 'Save my routine'),
          ),
        ],
      ),
    );
  }
}

class _TemplatePickerSheet extends StatelessWidget {
  const _TemplatePickerSheet({
    required this.templates,
    required this.savedTaskTemplates,
  });

  final List<RoutineTemplate> templates;
  final List<RoutineTemplate> savedTaskTemplates;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.78,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withOpacity(0.62),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    child: const Icon(Icons.auto_awesome_rounded),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Start from something friendly',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900)),
                        Text(
                          'Choose a template, then remix every word until it fits.',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (savedTaskTemplates.isNotEmpty) ...<Widget>[
              Text('Saved from tasks',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
            ],
            ...templates.map(
              (template) => _TemplateCard(
                template: template,
                savedFromTask: savedTaskTemplates.contains(template),
                onTap: () => Navigator.pop(context, template),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.savedFromTask,
    required this.onTap,
  });

  final RoutineTemplate template;
  final bool savedFromTask;
  final VoidCallback onTap;

  static const List<Color> _colors = <Color>[
    Color(0xFFFFE0B2),
    Color(0xFFC8E6C9),
    Color(0xFFBBDEFB),
    Color(0xFFE1BEE7),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[template.id.hashCode.abs() % _colors.length];
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: color.withOpacity(0.48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.72),
          child: const Icon(Icons.route_rounded),
        ),
        title: Text(template.title,
            style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(
          '${template.steps.length} steps • ${template.category}${savedFromTask ? ' • saved task' : ''}',
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      ),
    );
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

  static const List<Color> _accentColors = <Color>[
    Color(0xFF7C4DFF),
    Color(0xFF00ACC1),
    Color(0xFFFF8A65),
    Color(0xFF66BB6A),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = _accentColors[index % _accentColors.length];
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: accent.withOpacity(0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(color: accent, fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                controller: controller,
                hintText: 'Step ${index + 1}: make it tiny and clear',
                maxLines: 2,
                suffixIcon: VoiceInputButton(
                  onTextChanged: (text) => controller.text = text,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Column(
              children: <Widget>[
                IconButton(
                  tooltip: 'Move up',
                  onPressed: canMoveUp ? onMoveUp : null,
                  icon: const Icon(Icons.keyboard_arrow_up_rounded),
                ),
                IconButton(
                  tooltip: 'Move down',
                  onPressed: canMoveDown ? onMoveDown : null,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
                IconButton(
                  tooltip: 'Delete step',
                  onPressed: canDelete ? onDelete : null,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
