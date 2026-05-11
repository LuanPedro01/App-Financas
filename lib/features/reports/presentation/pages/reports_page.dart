import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:financeiro/core/extensions/number_extensions.dart';
import 'package:financeiro/core/extensions/date_extensions.dart';
import 'package:financeiro/core/theme/app_colors.dart';
import 'package:financeiro/core/theme/app_spacing.dart';
import 'package:financeiro/core/theme/app_typography.dart';
import 'package:financeiro/features/transactions/providers/transaction_provider.dart';
import 'package:financeiro/features/transactions/domain/entities/transaction.dart';
import 'package:financeiro/shared/widgets/glass_card.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mensal'),
            Tab(text: 'Categorias'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MonthlyReport(
            selectedMonth: _selectedMonth,
            onMonthChanged: (d) => setState(() => _selectedMonth = d),
          ),
          _CategoryReport(selectedMonth: _selectedMonth),
        ],
      ),
    );
  }
}

class _MonthlyReport extends ConsumerWidget {
  const _MonthlyReport({
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final allTxs = ref.watch(transactionProvider).transactions;

    final monthTxs = allTxs
        .where((t) =>
            t.date.month == selectedMonth.month &&
            t.date.year == selectedMonth.year,)
        .toList();

    final income = monthTxs
        .where((t) => t.isIncome && t.isCompleted)
        .fold(0.0, (s, t) => s + t.amount);
    final expense = monthTxs
        .where((t) => t.isExpense && t.isCompleted)
        .fold(0.0, (s, t) => s + t.amount);
    final balance = income - expense;

    // Build 6-month trend
    final now = DateTime.now();
    final months = List.generate(6, (i) => DateTime(now.year, now.month - (5 - i)));

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        children: [
          // Month Navigator
          Padding(
            padding: const EdgeInsets.all(AppSpacing.pageHPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () =>
                      onMonthChanged(selectedMonth.prevMonth),
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                ),
                Text(
                  selectedMonth.monthYear,
                  style: AppTypography.h6.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: selectedMonth.isSameMonth(now)
                      ? null
                      : () => onMonthChanged(selectedMonth.nextMonth),
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                ),
              ],
            ),
          ),

          // Summary Cards
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHPadding,),
            child: Row(
              children: [
                Expanded(
                  child: AppCard(
                    child: Column(
                      children: [
                        const Icon(Icons.arrow_downward_rounded,
                            color: AppColors.income, size: 20,),
                        const SizedBox(height: 4),
                        Text('Receitas',
                            style: AppTypography.caption.copyWith(
                                color: scheme.onSurfaceVariant,),),
                        const SizedBox(height: 4),
                        Text(income.brlCompact,
                            style: AppTypography.numericSmall.copyWith(
                                color: AppColors.income,),),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppCard(
                    child: Column(
                      children: [
                        const Icon(Icons.arrow_upward_rounded,
                            color: AppColors.expense, size: 20,),
                        const SizedBox(height: 4),
                        Text('Despesas',
                            style: AppTypography.caption.copyWith(
                                color: scheme.onSurfaceVariant,),),
                        const SizedBox(height: 4),
                        Text(expense.brlCompact,
                            style: AppTypography.numericSmall.copyWith(
                                color: AppColors.expense,),),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppCard(
                    child: Column(
                      children: [
                        Icon(
                          balance >= 0
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          color: balance >= 0
                              ? AppColors.income
                              : AppColors.expense,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text('Saldo',
                            style: AppTypography.caption.copyWith(
                                color: scheme.onSurfaceVariant,),),
                        const SizedBox(height: 4),
                        Text(
                          balance.brlCompact,
                          style: AppTypography.numericSmall.copyWith(
                            color: balance >= 0
                                ? AppColors.income
                                : AppColors.expense,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Trend Chart
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHPadding,),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tendência — últimos 6 meses',
                    style: AppTypography.h6
                        .copyWith(color: scheme.onSurface),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: scheme.outlineVariant.withValues(alpha: 0.3),
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, m) {
                                final i = v.toInt();
                                if (i < 0 || i >= months.length) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  months[i].monthShort,
                                  style: AppTypography.caption.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                );
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
                        lineBarsData: [
                          // Income line
                          LineChartBarData(
                            spots: months.asMap().entries.map((e) {
                              final m = e.value;
                              final v = allTxs
                                  .where((t) =>
                                      t.isIncome &&
                                      t.isCompleted &&
                                      t.date.month == m.month &&
                                      t.date.year == m.year,)
                                  .fold(0.0, (s, t) => s + t.amount);
                              return FlSpot(e.key.toDouble(), v);
                            }).toList(),
                            isCurved: true,
                            color: AppColors.income,
                            barWidth: 2.5,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.income.withValues(alpha: 0.08),
                            ),
                          ),
                          // Expense line
                          LineChartBarData(
                            spots: months.asMap().entries.map((e) {
                              final m = e.value;
                              final v = allTxs
                                  .where((t) =>
                                      t.isExpense &&
                                      t.isCompleted &&
                                      t.date.month == m.month &&
                                      t.date.year == m.year,)
                                  .fold(0.0, (s, t) => s + t.amount);
                              return FlSpot(e.key.toDouble(), v);
                            }).toList(),
                            isCurved: true,
                            color: AppColors.expense,
                            barWidth: 2.5,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.expense.withValues(alpha: 0.08),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate(delay: const Duration(milliseconds: 100)).fadeIn(),
          ),
        ],
      ),
    );
  }
}

class _CategoryReport extends ConsumerWidget {
  const _CategoryReport({required this.selectedMonth});

  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final allTxs = ref.watch(transactionProvider).transactions;

    final expenses = allTxs
        .where((t) =>
            t.isExpense &&
            t.isCompleted &&
            t.date.month == selectedMonth.month &&
            t.date.year == selectedMonth.year,)
        .toList();

    final byCategory = <String, double>{};
    for (final t in expenses) {
      final cat = t.categoryName ?? 'Sem categoria';
      byCategory[cat] = (byCategory[cat] ?? 0) + t.amount;
    }

    final sorted = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = sorted.fold(0.0, (s, e) => s + e.value);

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.pageHPadding),
      itemCount: sorted.length + 1,
      itemBuilder: (ctx, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total gasto — ${selectedMonth.monthYear}',
                    style: AppTypography.labelMedium
                        .copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    total.brl,
                    style:
                        AppTypography.numericLarge.copyWith(color: AppColors.expense),
                  ),
                ],
              ),
            ).animate().fadeIn(),
          );
        }

        final entry = sorted[i - 1];
        final pct = total > 0 ? entry.value / total : 0.0;
        final color = AppColors.chartPalette[(i - 1) % AppColors.chartPalette.length];

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: AppCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: AppTypography.labelMedium
                            .copyWith(color: scheme.onSurface),
                      ),
                    ),
                    Text(
                      entry.value.brl,
                      style: AppTypography.numericSmall
                          .copyWith(color: scheme.onSurface),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      pct.percentRaw,
                      style: AppTypography.caption
                          .copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          )
              .animate(delay: Duration(milliseconds: i * 50))
              .fadeIn()
              .slideX(begin: 0.05),
        );
      },
    );
  }
}
