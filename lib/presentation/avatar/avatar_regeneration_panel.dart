import 'package:flutter/material.dart';

import '../../domain/avatar/avatar_refinement_request.dart';

class AvatarRegenerationPanel extends StatelessWidget {
  const AvatarRegenerationPanel({
    super.key,
    required this.onSelected,
    this.enabled = true,
  });

  final ValueChanged<AvatarRefinementIntent> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final items = <_RegenerationAction>[
      _RegenerationAction(
        AvatarRefinementIntent.tryAgain,
        'Try again',
        Icons.refresh,
      ),
      _RegenerationAction(
        AvatarRefinementIntent.softer,
        'Make softer',
        Icons.spa_outlined,
      ),
      _RegenerationAction(
        AvatarRefinementIntent.moreRealistic,
        'More realistic',
        Icons.face_retouching_natural,
      ),
      _RegenerationAction(
        AvatarRefinementIntent.lessRealistic,
        'Less realistic',
        Icons.brush_outlined,
      ),
      _RegenerationAction(
        AvatarRefinementIntent.warmerLighting,
        'Warmer light',
        Icons.wb_sunny_outlined,
      ),
      _RegenerationAction(
        AvatarRefinementIntent.coolerLighting,
        'Cooler light',
        Icons.ac_unit,
      ),
      _RegenerationAction(
        AvatarRefinementIntent.calmerExpression,
        'Calmer',
        Icons.self_improvement,
      ),
      _RegenerationAction(
        AvatarRefinementIntent.happierExpression,
        'Happier',
        Icons.sentiment_satisfied_alt,
      ),
      _RegenerationAction(
        AvatarRefinementIntent.fixHair,
        'Fix hair',
        Icons.content_cut,
      ),
      _RegenerationAction(
        AvatarRefinementIntent.fixSkinTone,
        'Fix skin tone',
        Icons.palette_outlined,
      ),
      _RegenerationAction(
        AvatarRefinementIntent.fixAccessibilityItem,
        'Fix accessibility item',
        Icons.accessibility_new,
      ),
      _RegenerationAction(
        AvatarRefinementIntent.fixCulturalItem,
        'Fix headwear/culture item',
        Icons.checkroom,
      ),
      _RegenerationAction(
        AvatarRefinementIntent.useAbstractInstead,
        'Use abstract instead',
        Icons.blur_circular,
      ),
    ];

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Refine avatar',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                return ActionChip(
                  avatar: Icon(item.icon, size: 18),
                  label: Text(item.label),
                  onPressed: enabled ? () => onSelected(item.intent) : null,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegenerationAction {
  const _RegenerationAction(this.intent, this.label, this.icon);

  final AvatarRefinementIntent intent;
  final String label;
  final IconData icon;
}
