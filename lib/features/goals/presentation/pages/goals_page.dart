import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:financeiro/app/router/route_paths.dart';
import 'package:financeiro/core/extensions/number_extensions.dart';
import 'package:financeiro/core/theme/app_colors.dart';
import 'package:financeiro/core/theme/app_spacing.dart';
import 'package:financeiro/core/theme/app_typography.dart';
import 'package:financeiro/features/goals/providers/goals_provider.dart';
import 'package:financeiro/features/goals/data/models/goal_model.dart';
import 'package:financeiro/shared/widgets/empty_state.dart';
import 'package:financeiro/shared/widgets/glass_card.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas financeiras'),
        actions: [
          IconButton(
            onPressed: () => context.push(RoutePaths.addGoal),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (goals) => goals.isEmpty
            ? EmptyGoals(onAdd: () => context.push(RoutePaths.addGoal))
            : ListView.builder(
                padding: const EdgeInsets.only(
                  top: AppSpacing.lg,
                  left: AppSpacing.pageHPadding,
                  right: AppSpacing.pageHPadding,
                  bottom: 100,
                ),
                itemCount: goals.length,
                itemBuilder: (ctx, i) => _GoalCard(goal: goals[i], index: i),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.addGoal),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova meta'),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal, required this.index});

  final GoalModel goal;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = Color(goal.color);
    final progress = goal.progress;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        onTap: () =>
            context.push(RoutePaths.goalDetailPath(goal.id.toString())),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(goal.icon, style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: AppTypography.labelLarge.copyWith(
                          color: scheme.onBackground,
                        ),
                      ),
                      Text(
                        goal.type.label,
                        style: AppTypography.caption.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      goal.currentAmount.brlCompact,
                      style: AppTypography.numericSmall.copyWith(color: color),
                    ),
                    Text(
                      'de ${goal.targetAmount.brlCompact}',
                      style: AppTypography.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: color.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(1)}% concluído',
                  style: AppTypography.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Falta ${goal.remaining.brlCompact}',
                  style: AppTypography.caption.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: index * 80))
          .fadeIn()
          .slideY(begin: 0.1),
    );
  }
}

// ─── Stub pages ───────────────────────────────────────────────────────────────
class AddGoalPage extends StatelessWidget {
  const AddGoalPage({super.key, this.editId});
  final String? editId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editId != null ? 'Editar meta' : 'Nova meta'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: const Center(child: Text('Formulário de meta')),
    );
  }
}

class GoalDetailPage extends StatelessWidget {
  const GoalDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da meta')),
      body: const Center(child: Text('Detalhes da meta')),
    );
  }
}
