import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:financeiro/app/router/route_paths.dart';
import 'package:financeiro/core/extensions/number_extensions.dart';
import 'package:financeiro/core/extensions/date_extensions.dart';
import 'package:financeiro/core/theme/app_colors.dart';
import 'package:financeiro/core/theme/app_spacing.dart';
import 'package:financeiro/core/theme/app_typography.dart';
import 'package:financeiro/features/accounts/providers/accounts_provider.dart';
import 'package:financeiro/features/transactions/providers/transaction_provider.dart';
import 'package:financeiro/features/goals/providers/goals_provider.dart';
import 'package:financeiro/features/settings/providers/settings_provider.dart';
import 'package:financeiro/features/transactions/domain/enums/transaction_enums.dart';
import 'package:financeiro/features/transactions/domain/entities/transaction.dart';
import 'package:financeiro/shared/widgets/glass_card.dart';
import 'package:financeiro/shared/widgets/transaction_tile.dart';
import 'package:financeiro/shared/widgets/amount_display.dart';
import 'package:financeiro/shared/widgets/skeleton_loading.dart';
import 'package:financeiro/shared/widgets/empty_state.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final txState = ref.watch(transactionProvider);

    if (txState.isLoading && txState.transactions.isEmpty) {
      return const Scaffold(body: DashboardSkeleton());
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(accountsProvider);
          ref.invalidate(transactionProvider);
          await Future.delayed(const Duration(milliseconds: 600));
        },
        child: CustomScrollView(
          slivers: [
            _DashboardAppBar(),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Balance Card ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHPadding,
                    ),
                    child: _BalanceCard(),
                  ).animate().fadeIn().slideY(begin: 0.1),

                  const SizedBox(height: AppSpacing.lg),

                  // ─── Income / Expense Row ─────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHPadding,
                    ),
                    child: _IncomeExpenseRow(),
                  )
                      .animate(delay: const Duration(milliseconds: 100))
                      .fadeIn()
                      .slideY(begin: 0.1),

                  const SizedBox(height: AppSpacing.xl2),

                  // ─── Quick Actions ────────────────────────────────────
                  _QuickActions()
                      .animate(delay: const Duration(milliseconds: 150))
                      .fadeIn(),

                  const SizedBox(height: AppSpacing.xl2),

                  // ─── Monthly Chart ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHPadding,
                    ),
                    child: _MonthlyChart(),
                  )
                      .animate(delay: const Duration(milliseconds: 200))
                      .fadeIn()
                      .slideY(begin: 0.1),

                  const SizedBox(height: AppSpacing.xl2),

                  // ─── Active Goals ─────────────────────────────────────
                  _GoalsSection()
                      .animate(delay: const Duration(milliseconds: 250))
                      .fadeIn(),

                  const SizedBox(height: AppSpacing.xl2),

                  // ─── Recent Transactions ──────────────────────────────
                  _RecentTransactions()
                      .animate(delay: const Duration(milliseconds: 300))
                      .fadeIn(),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────
class _DashboardAppBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsProvider);
    final now = DateTime.now();

    final greeting = now.hour < 12
        ? 'Bom dia'
        : now.hour < 18
            ? 'Boa tarde'
            : 'Boa noite';

    return SliverAppBar(
      floating: true,
      backgroundColor: scheme.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting,',
            style: AppTypography.bodySmall.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          Text(
            settings.userName,
            style: AppTypography.h5.copyWith(
              color: scheme.onBackground,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            ref.read(settingsProvider.notifier).toggleHideBalance();
            HapticFeedback.lightImpact();
          },
          icon: Icon(
            settings.hideBalance
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            color: scheme.onSurfaceVariant,
          ),
        ),
        IconButton(
          onPressed: () => context.push(RoutePaths.settings),
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: scheme.primaryContainer,
            child: Text(
              settings.userName.isNotEmpty ? settings.userName[0].toUpperCase() : 'U',
              style: AppTypography.labelMedium.copyWith(
                color: scheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }
}

// ─── Balance Card ─────────────────────────────────────────────────────────────
class _BalanceCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalBalance = ref.watch(totalBalanceProvider);
    final income = ref.watch(currentMonthIncomeProvider);
    final expense = ref.watch(currentMonthExpenseProvider);
    final netFlow = income - expense;
    final now = DateTime.now();

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A87E3),
            Color(0xFF7B4CF5),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand500.withOpacity(0.3),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saldo Total',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white70,
                    letterSpacing: 0.8,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    now.monthYear,
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AmountDisplay(
              amount: totalBalance,
              style: AppTypography.numericDisplay.copyWith(
                color: Colors.white,
                fontSize: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'Receitas',
                    amount: income,
                    icon: Icons.arrow_downward_rounded,
                    color: const Color(0xFF4ADE80),
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.2),
                ),
                Expanded(
                  child: _MiniStat(
                    label: 'Despesas',
                    amount: expense,
                    icon: Icons.arrow_upward_rounded,
                    color: const Color(0xFFF87171),
                    isExpense: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends ConsumerWidget {
  const _MiniStat({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    this.isExpense = false,
  });

  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final bool isExpense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: Colors.white60,
                ),
              ),
              AmountDisplay(
                amount: amount,
                style: AppTypography.numericSmall.copyWith(
                  color: Colors.white,
                ),
                compact: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Income / Expense Row ─────────────────────────────────────────────────────
class _IncomeExpenseRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final income = ref.watch(currentMonthIncomeProvider);
    final expense = ref.watch(currentMonthExpenseProvider);
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: AppCard(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.income.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_downward_rounded,
                    color: AppColors.income,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Entradas',
                        style: AppTypography.caption.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AmountDisplay(
                        amount: income,
                        style: AppTypography.numericSmall.copyWith(
                          color: AppColors.income,
                        ),
                        compact: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppCard(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.expense.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_upward_rounded,
                    color: AppColors.expense,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saídas',
                        style: AppTypography.caption.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AmountDisplay(
                        amount: expense,
                        style: AppTypography.numericSmall.copyWith(
                          color: AppColors.expense,
                        ),
                        compact: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Quick Actions ────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  static const _actions = [
    _QuickAction(
      icon: Icons.add_rounded,
      label: 'Despesa',
      color: AppColors.expense,
      route: RoutePaths.addTransaction,
      queryParams: {'type': 'expense'},
    ),
    _QuickAction(
      icon: Icons.add_rounded,
      label: 'Receita',
      color: AppColors.income,
      route: RoutePaths.addTransaction,
      queryParams: {'type': 'income'},
    ),
    _QuickAction(
      icon: Icons.swap_horiz_rounded,
      label: 'Transferir',
      color: AppColors.transfer,
      route: RoutePaths.addTransaction,
      queryParams: {'type': 'transfer'},
    ),
    _QuickAction(
      icon: Icons.bar_chart_rounded,
      label: 'Relatórios',
      color: AppColors.accent500,
      route: RoutePaths.reports,
    ),
    _QuickAction(
      icon: Icons.credit_card_rounded,
      label: 'Cartões',
      color: AppColors.warning500,
      route: RoutePaths.cards,
    ),
    _QuickAction(
      icon: Icons.trending_up_rounded,
      label: 'Invest.',
      color: AppColors.investment,
      route: RoutePaths.investments,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHPadding),
        itemCount: _actions.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppSpacing.md),
        itemBuilder: (ctx, i) => _QuickActionButton(
          action: _actions[i],
          index: i,
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.action, required this.index});

  final _QuickAction action;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (action.queryParams != null) {
          final params = action.queryParams!.entries
              .map((e) => '${e.key}=${e.value}')
              .join('&');
          context.push('${action.route}?$params');
        } else {
          context.push(action.route);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: action.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: action.color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(action.icon, color: action.color, size: 24),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            action.label,
            style: AppTypography.caption.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 300 + index * 40))
        .fadeIn(duration: const Duration(milliseconds: 300))
        .slideX(
          begin: 0.2,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
    this.queryParams,
  });

  final IconData icon;
  final String label;
  final Color color;
  final String route;
  final Map<String, String>? queryParams;
}

// ─── Monthly Chart ────────────────────────────────────────────────────────────
class _MonthlyChart extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final allTxs = ref.watch(transactionProvider).transactions;

    // Build last 6 months data
    final now = DateTime.now();
    final months = List.generate(6, (i) {
      final d = DateTime(now.year, now.month - (5 - i), 1);
      return d;
    });

    final incomeData = months.map((m) {
      return allTxs
          .where((t) =>
              t.type == TransactionType.income &&
              t.date.month == m.month &&
              t.date.year == m.year &&
              t.isCompleted)
          .fold(0.0, (s, t) => s + t.amount);
    }).toList();

    final expenseData = months.map((m) {
      return allTxs
          .where((t) =>
              t.type == TransactionType.expense &&
              t.date.month == m.month &&
              t.date.year == m.year &&
              t.isCompleted)
          .fold(0.0, (s, t) => s + t.amount);
    }).toList();

    final maxY =
        [...incomeData, ...expenseData].reduce((a, b) => a > b ? a : b);
    final yInterval = maxY > 0 ? (maxY / 4).ceilToDouble() : 1000.0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fluxo mensal',
                style: AppTypography.h6.copyWith(
                  color: scheme.onBackground,
                ),
              ),
              GestureDetector(
                onTap: () => context.push(RoutePaths.reports),
                child: Text(
                  'Ver mais',
                  style: AppTypography.labelSmall.copyWith(
                    color: scheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Legend
          Row(
            children: [
              _ChartLegend(color: AppColors.income, label: 'Receitas'),
              const SizedBox(width: AppSpacing.lg),
              _ChartLegend(color: AppColors.expense, label: 'Despesas'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, gi, rod, ri) {
                      final isIncome = ri == 0;
                      return BarTooltipItem(
                        rod.toY.brlCompact,
                        AppTypography.labelSmall.copyWith(
                          color: isIncome ? AppColors.income : AppColors.expense,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < months.length) {
                          return Text(
                            months[idx].monthShort,
                            style: AppTypography.caption.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: yInterval,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: scheme.outlineVariant.withOpacity(0.3),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(months.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: incomeData[i],
                        color: AppColors.income,
                        width: 8,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: expenseData[i],
                        color: AppColors.expense,
                        width: 8,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                    barsSpace: 4,
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ─── Goals Section ────────────────────────────────────────────────────────────
class _GoalsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final goals = ref.watch(activeGoalsProvider);

    if (goals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Metas ativas',
                style: AppTypography.h6.copyWith(
                  color: scheme.onBackground,
                ),
              ),
              GestureDetector(
                onTap: () => context.push(RoutePaths.goals),
                child: Text(
                  'Ver todas',
                  style: AppTypography.labelSmall.copyWith(
                    color: scheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHPadding),
            itemCount: goals.length.clamp(0, 5),
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppSpacing.md),
            itemBuilder: (ctx, i) {
              final goal = goals[i];
              final color = Color(goal.color);
              final progress = goal.progress;

              return AppCard(
                width: 200,
                onTap: () =>
                    ctx.push(RoutePaths.goalDetailPath(goal.id.toString())),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.flag_rounded,
                              color: color, size: 16),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            goal.name,
                            style: AppTypography.labelMedium.copyWith(
                              color: scheme.onBackground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      goal.currentAmount.brlCompact,
                      style: AppTypography.numericSmall.copyWith(
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'de ${goal.targetAmount.brlCompact}',
                      style: AppTypography.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: color.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: AppTypography.overline.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Recent Transactions ──────────────────────────────────────────────────────
class _RecentTransactions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final txs = ref.watch(recentTransactionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Últimas transações',
                style: AppTypography.h6.copyWith(
                  color: scheme.onBackground,
                ),
              ),
              GestureDetector(
                onTap: () => context.push(RoutePaths.transactions),
                child: Text(
                  'Ver todas',
                  style: AppTypography.labelSmall.copyWith(
                    color: scheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (txs.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl2),
            child: EmptyTransactions(
              onAdd: () => context.push(RoutePaths.addTransaction),
            ),
          )
        else
          Column(
            children: [
              for (int i = 0; i < txs.length.clamp(0, 5); i++)
                TransactionTile(
                  transaction: txs[i],
                  onTap: () => context.push(
                    RoutePaths.transactionDetailPath(txs[i].id.toString()),
                  ),
                  animationIndex: i,
                ),
            ],
          ),
      ],
    );
  }
}
