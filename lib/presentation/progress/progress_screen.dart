import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/primary_scaffold.dart';
import '../../providers.dart';
import 'progress_controller.dart';
import 'progress_view_state.dart';

import '../../domain/rewards/reward_points.dart';
import '../rewards/widgets/xp_bar.dart';
import '../core/widgets/dopei_guide.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authUser = ref.read(authRepositoryProvider).getCurrentUser();
      if (authUser != null) {
        ref.read(progressControllerProvider.notifier).load(authUser.id);
      } else {
        ref.read(progressControllerProvider.notifier).loadLocalFallback();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(progressControllerProvider);

    return PrimaryScaffold(
      title: 'Progress Dashboard',
      leading: IconButton(
        tooltip: 'Back',
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
      ),
      child: state.when(
        data: (viewState) => RefreshIndicator(
          onRefresh: () async {
            final authUser = ref.read(authRepositoryProvider).getCurrentUser();
            if (authUser != null) {
              await ref
                  .read(progressControllerProvider.notifier)
                  .load(authUser.id);
            }
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: DopeiGuide(
                    text: _getEncouragement(viewState),
                    mood: viewState.stats.level > 1
                        ? DopeiMood.happy
                        : DopeiMood.calm,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _SummaryCards(viewState: viewState),
                    const SizedBox(height: 32),
                    Text('Focus Consistency',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _UserFocusHeatmap(),
                    const SizedBox(height: 32),
                    Text('Task Achievements',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final task = viewState.completedTasks[index];
                    return _TaskAchievementTile(task: task);
                  },
                  childCount: viewState.completedTasks.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            _ProgressContent(viewState: ProgressViewState.initial()),
      ),
    );
  }

  String _getEncouragement(ProgressViewState state) {
    if (state.stats.currentStreak > 2) {
      return "A ${state.stats.currentStreak}-day streak! You're building some serious momentum.";
    }
    if (state.stats.totalXp > 500) {
      return "Look at all that XP! You're becoming a focus master.";
    }
    return "Every small step you take is a win. I'm proud of the progress you're making!";
  }
}

class _ProgressContent extends StatelessWidget {
  const _ProgressContent({required this.viewState});

  final ProgressViewState viewState;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {},
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: DopeiGuide(
                text:
                    "Every small step you take is a win. I'm proud of the progress you're making!",
                mood: viewState.stats.level > 1
                    ? DopeiMood.happy
                    : DopeiMood.calm,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SummaryCards(viewState: viewState),
                const SizedBox(height: 32),
                Text('Focus Consistency',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _UserFocusHeatmap(),
                const SizedBox(height: 32),
                Text('Task Achievements',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
              ]),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final task = viewState.completedTasks[index];
                return _TaskAchievementTile(task: task);
              },
              childCount: viewState.completedTasks.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.viewState});
  final ProgressViewState viewState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _GlassCard(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.tertiary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LEVEL ${viewState.stats.level}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${viewState.stats.totalXp} Total XP',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              XPBar(
                level: viewState.stats.level,
                progress: viewState.stats.progressToNextLevel,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${viewState.stats.xpToNextLevel} XP until level ${viewState.stats.level + 1}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.white.withOpacity(0.8)),
                  ),
                  Icon(Icons.trending_up_rounded,
                      color: Colors.white.withOpacity(0.8), size: 16),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _GlassCard(
                gradient: LinearGradient(
                    colors: [Colors.indigo.shade700, Colors.blue.shade800]),
                child: Column(
                  children: [
                    Text('Reliability',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7))),
                    const SizedBox(height: 8),
                    Text('${viewState.reliabilityScore}',
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    const Text('POINTS',
                        style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            color: Colors.white60)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GlassCard(
                gradient: LinearGradient(colors: [
                  Colors.orange.shade800,
                  Colors.deepOrange.shade900
                ]),
                child: Column(
                  children: [
                    Text('Streak',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7))),
                    const SizedBox(height: 8),
                    Text('${viewState.stats.currentStreak}',
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    const Text('DAYS',
                        style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            color: Colors.white60)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child, required this.gradient});
  final Widget child;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _UserFocusHeatmap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((d) => Text(d,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey)))
                .toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: 28,
            itemBuilder: (context, index) {
              final opacity = (index * 7) % 10 / 10.0;
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(opacity.clamp(0.1, 1.0)),
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TaskAchievementTile extends StatelessWidget {
  const _TaskAchievementTile({required this.task});
  final Map<String, dynamic> task;

  @override
  Widget build(BuildContext context) {
    final steps = task['task_steps'] as List<dynamic>? ?? [];
    final completedCount = steps.where((s) {
      final step = Map<String, dynamic>.from(s as Map);
      return step['completion_status'] == 'completed' ||
          step['status'] == 'completed';
    }).length;
    final totalXp = completedCount * RewardPoints.taskCompleted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.stars_rounded,
              color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          task['normalized_title'] ?? 'Untitled Task',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '$completedCount steps completed • Focused Effort',
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '+$totalXp XP',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const Text(
              'EARNED',
              style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
