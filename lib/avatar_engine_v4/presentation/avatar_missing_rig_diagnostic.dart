import 'package:flutter/material.dart';

class AvatarMissingRigDiagnostic extends StatelessWidget {
  const AvatarMissingRigDiagnostic({
    super.key,
    required this.assetPath,
    this.size = 180,
    this.details,
  });

  final String assetPath;
  final double size;
  final String? details;

  @override
  Widget build(BuildContext context) {
    final safeSize = size <= 0 ? 180.0 : size;
    final theme = Theme.of(context);
    final compact = safeSize < 210;

    return Semantics(
      label: 'Avatar rig missing',
      child: Container(
        key: const ValueKey<String>('avatar-v4-missing-rig-diagnostic'),
        width: safeSize,
        height: safeSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(safeSize * .18),
          gradient: const LinearGradient(
            colors: <Color>[
              Color(0xFFF8FAFC),
              Color(0xFFEDE9FE),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFFEF4444), width: 2),
        ),
        padding: EdgeInsets.all(safeSize * .07),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: safeSize * .78,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.view_in_ar_outlined,
                  color: const Color(0xFFEF4444),
                  size: compact ? 30 : safeSize * .22,
                ),
                SizedBox(height: compact ? 6 : safeSize * .045),
                Text(
                  'Avatar rig missing',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF991B1B),
                    fontWeight: FontWeight.w700,
                    fontSize: compact ? 12 : null,
                  ),
                ),
                if (!compact) ...<Widget>[
                  SizedBox(height: safeSize * .030),
                  Text(
                    details ?? assetPath,
                    key: const ValueKey<String>('avatar-v4-rig-diagnostic-details'),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF7F1D1D),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
