import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:financeiro/core/extensions/number_extensions.dart';
import 'package:financeiro/core/theme/app_colors.dart';
import 'package:financeiro/core/theme/app_spacing.dart';
import 'package:financeiro/core/theme/app_typography.dart';
import 'package:financeiro/features/transactions/providers/transaction_provider.dart';
import 'package:financeiro/features/transactions/domain/enums/transaction_enums.dart';
import 'package:financeiro/shared/widgets/glass_card.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final allTxs = ref.watch(transactionProvider).transactions;

    // Monthly averages
    final now = DateTime.now();
    final months = List.generate(6, (i) => DateTime(now.year, now.month - (5 - i)));

    final monthlyExpenses = months.map((m) {
      return allTxs
          .where((t) =>
              t.isExpense &&
              t.isCompleted &&
              t.date.month == m.month &&
              t.date.year == m.year)
          .fold(0.0, (s, t) => s + t.amount);
    }).toList();

    final avgExpense =
        monthlyExpenses.isEmpty ? 0.0 : monthlyExpenses.reduce((a, b) => a + b) / monthlyExpenses.length;

    // Weekday distribution
    final byWeekday = List.filled(7, 0.0);
    for (final t in allTxs.where((t) => t.isExpense && t.isCompleted)) {
      byWeekday[t.date.weekday - 1] += t.amount;
    }
    final maxWeekday = byWeekday.reduce((a, b) => a > b ? a : b);

    const weekDays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.pageHPadding),
              child: Column(
                children: [
                  // Average expense card
                  AppCard(
                    gradient: const LinearGradient(
                      colors: [AppColors.dark700, AppColors.dark650],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Média mensal de gastos',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.dark200,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                avgExpense.brl,
                                style: AppTypography.numericLarge.copyWith(
                                  color: AppColors.expense,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Últimos 6 meses',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.dark300,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.analytics_rounded,
                          size: 48,
                          color: AppColors.dark400,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Heatmap by weekday
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gastos por dia da semana',
                          style: AppTypography.h6.copyWith(
                            color: scheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(7, (i) {
                            final value = byWeekday[i];
                            final height =
                                maxWeekday > 0 ? (value / maxWeekday * 80) : 0.0;
                            final isMax = value == maxWeekday && maxWeekday > 0;

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isMax)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      value.brlCompact,
                                      style: AppTypography.overline.copyWith(
                                        color: AppColors.expense,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeOutCubic,
                                  width: 28,
                                  height: height.clamp(4, 80),
                                  decoration: BoxDecoration(
                                    color: isMax
                                        ? AppColors.expense
                                        : AppColors.expense.withOpacity(
                                            value > 0 ? 0.4 : 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  weekDays[i],
                                  style: AppTypography.overline.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Monthly evolution (net balance)
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Evolução patrimonial',
                          style: AppTypography.h6.copyWith(
                            color: scheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        SizedBox(
                          height: 150,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              barGroups: months.asMap().entries.map((e) {
                                final m = e.value;
                                final income = allTxs
                                    .where((t) =>
                                        t.isIncome &&
                                        t.isCompleted &&
                                        t.date.month == m.month &&
                                        t.date.year == m.year)
                                    .fold(0.0, (s, t) => s + t.amount);
                                final expense = allTxs
                                    .where((t) =>
                                        t.isExpense &&
                                        t.isCompleted &&
                                        t.date.month == m.month &&
                                        t.date.year == m.year)
                                    .fold(0.0, (s, t) => s + t.amount);
                                final net = income - expense;

                                return BarChartGroupData(
                                  x: e.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: net.abs(),
                                      color: net >= 0
                                          ? AppColors.income
                                          : AppColors.expense,
                                      width: 16,
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                  ],
                                );
                              }).toList(),
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
                                    sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
