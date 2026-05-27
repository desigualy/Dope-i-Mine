import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dope_i_mine/app/theme/color_tokens.dart';
import 'package:dope_i_mine/core/sync/sync_queue_service.dart';
import 'package:dope_i_mine/domain/body_double/body_double_session.dart';
import 'package:dope_i_mine/presentation/body_double/body_double_controller.dart';
import 'package:dope_i_mine/providers.dart';

class PrimaryActionCard extends ConsumerWidget {
  const PrimaryActionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(localTaskSessionCacheProvider).load(),
      builder: (context, snapshot) {
        final hasActiveTask = snapshot.data != null;
        final bdState = ref.watch(bodyDoubleControllerProvider);
        final hasActiveBodyDouble = bdState.activeSession != null &&
            bdState.activeSession!.status == BodyDoubleStatus.active;

        String title;
        String subtitle;
        IconData icon;
        VoidCallback onPressed;

        if (hasActiveBodyDouble) {
          title = 'Continue support';
          subtitle = 'Return to your active body-double session';
          icon = Icons.groups_2_rounded;
          onPressed = () => context.go('/body-double/session');
        } else if (hasActiveTask) {
          title = 'Continue task';
          subtitle = 'Pick up where you left off';
          icon = Icons.play_arrow_rounded;
          onPressed = () => context.go('/tasks/breakdown');
        } else {
          title = 'Start from something friendly';
          subtitle = 'Choose a template, then remix it until it fits.';
          icon = Icons.auto_awesome_rounded;
          onPressed = () => context.go('/tasks/new');
        }

        return _TemplateActionButton(
          key: const ValueKey<String>('home-menu-task-action'),
          icon: icon,
          title: title,
          subtitle: subtitle,
          onPressed: onPressed,
          trailing: FutureBuilder<int>(
            future: ref.read(syncQueueServiceProvider).pendingCount(),
            builder: (context, pendingSnapshot) {
              final count = pendingSnapshot.data ?? 0;
              if (pendingSnapshot.connectionState != ConnectionState.done ||
                  count == 0) {
                return const Icon(Icons.chevron_right_rounded);
              }
              return Text(
                '$count sync',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: ColorTokens.homeSubtext,
                      fontWeight: FontWeight.w700,
                    ),
              );
            },
          ),
        );
      },
    );
  }
}

class _TemplateActionButton extends StatelessWidget {
  const _TemplateActionButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
    this.trailing = const Icon(Icons.chevron_right_rounded),
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: ColorTokens.homePromptCard,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 25,
                backgroundColor: ColorTokens.homePromptIconWell,
                child: Icon(icon, color: ColorTokens.homePromptCard),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: ColorTokens.homeText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ColorTokens.homeSubtext,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconTheme(
                data: const IconThemeData(color: ColorTokens.homeSubtext),
                child: trailing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
