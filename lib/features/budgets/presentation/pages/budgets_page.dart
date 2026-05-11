import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:financeiro/app/router/route_paths.dart';
import 'package:financeiro/core/extensions/number_extensions.dart';
import 'package:financeiro/core/theme/app_colors.dart';
import 'package:financeiro/core/theme/app_spacing.dart';
import 'package:financeiro/core/theme/app_typography.dart';
import 'package:financeiro/features/budgets/providers/budgets_provider.dart';
import 'package:financeiro/features/budgets/data/models/budget_model.dart';
import 'package:financeiro/shared/widgets/glass_card.dart';

class BudgetsPage extends ConsumerWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamentos'),
        actions: [
          IconButton(
            onPressed: () => context.push(RoutePaths.addBudget),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: budgetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (budgets) => budgets.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.account_balance_outlined,
                      size: 64,
                      color: AppColors.dark300,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Nenhum orçamento',
                      style: AppTypography.h5.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Crie orçamentos para controlar seus gastos por categoria.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl2),
                    FilledButton.icon(
                      onPressed: () => context.push(RoutePaths.addBudget),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Criar orçamento'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(
                  top: AppSpacing.lg,
                  left: AppSpacing.pageHPadding,
                  right: AppSpacing.pageHPadding,
                  bottom: 100,
                ),
                itemCount: budgets.length,
                itemBuilder: (ctx, i) =>
                    _BudgetCard(budget: budgets[i], index: i),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.addBudget),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo orçamento'),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.budget, required this.index});

  final BudgetModel budget;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = Color(budget.categoryColor);
    final progress = budget.progress;

    final progressColor = budget.isOverBudget
        ? AppColors.error500
        : budget.isNearLimit
            ? AppColors.warning500
            : color;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.category_rounded, color: color, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    budget.categoryName,
                    style: AppTypography.labelLarge.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      budget.spent.brlCompact,
                      style: AppTypography.numericSmall.copyWith(
                        color: progressColor,
                      ),
                    ),
                    Text(
                      'de ${budget.amount.brlCompact}',
                      style: AppTypography.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: progressColor.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation(progressColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (budget.isOverBudget)
                  Text(
                    'Limite excedido!',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.error500,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else if (budget.isNearLimit)
                  Text(
                    'Próximo do limite',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.warning500,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: AppTypography.caption.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                Text(
                  'Disponível: ${budget.remaining.brlCompact}',
                  style: AppTypography.caption.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: index * 60))
          .fadeIn()
          .slideY(begin: 0.1),
    );
  }
}

class AddBudgetPage extends StatelessWidget {
  const AddBudgetPage({super.key, this.editId});
  final String? editId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editId != null ? 'Editar orçamento' : 'Novo orçamento'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: const Center(child: Text('Formulário de orçamento')),
    );
  }
}
