import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:financeiro/app/router/route_paths.dart';
import 'package:financeiro/core/extensions/number_extensions.dart';
import 'package:financeiro/core/theme/app_colors.dart';
import 'package:financeiro/core/theme/app_spacing.dart';
import 'package:financeiro/core/theme/app_typography.dart';
import 'package:financeiro/features/investments/providers/investments_provider.dart';
import 'package:financeiro/features/investments/data/models/investment_model.dart';
import 'package:financeiro/shared/widgets/empty_state.dart';
import 'package:financeiro/shared/widgets/glass_card.dart';
import 'package:financeiro/shared/widgets/amount_display.dart';

class InvestmentsPage extends ConsumerWidget {
  const InvestmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investmentsAsync = ref.watch(investmentsProvider);
    final portfolioTotal = ref.watch(portfolioTotalProvider);
    final portfolioInvested = ref.watch(portfolioInvestedProvider);
    final profitLoss = ref.watch(portfolioProfitLossProvider);
    final scheme = Theme.of(context).colorScheme;
    final isProfitable = profitLoss >= 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investimentos'),
        actions: [
          IconButton(
            onPressed: () => context.push(RoutePaths.addInvestment),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: investmentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (investments) => investments.isEmpty
            ? EmptyInvestments(
                onAdd: () => context.push(RoutePaths.addInvestment),
              )
            : CustomScrollView(
                slivers: [
                  // Portfolio Summary
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.pageHPadding),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF1C1F28),
                                  Color(0xFF222631),
                                ],
                              ),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.cardRadius),
                            ),
                            padding: AppSpacing.cardInsets,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Patrimônio investido',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.dark200,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                AmountDisplay(
                                  amount: portfolioTotal,
                                  style: AppTypography.numericLarge.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Investido',
                                            style: AppTypography.caption
                                                .copyWith(
                                              color: AppColors.dark300,
                                            ),
                                          ),
                                          Text(
                                            portfolioInvested.brlCompact,
                                            style: AppTypography.numericSmall
                                                .copyWith(
                                              color: AppColors.dark100,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Rentabilidade',
                                            style: AppTypography.caption
                                                .copyWith(
                                              color: AppColors.dark300,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                isProfitable
                                                    ? Icons
                                                        .trending_up_rounded
                                                    : Icons
                                                        .trending_down_rounded,
                                                color: isProfitable
                                                    ? AppColors.income
                                                    : AppColors.expense,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${isProfitable ? '+' : ''}${profitLoss.brlCompact}',
                                                style: AppTypography.numericSmall
                                                    .copyWith(
                                                  color: isProfitable
                                                      ? AppColors.income
                                                      : AppColors.expense,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Allocation Chart
                          if (investments.length > 1) ...[
                            const SizedBox(height: AppSpacing.lg),
                            AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Alocação',
                                    style: AppTypography.h6.copyWith(
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  SizedBox(
                                    height: 180,
                                    child: _AllocationChart(
                                      investments: investments,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ).animate().fadeIn(),
                    ),
                  ),

                  // Investments list
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pageHPadding,
                      ),
                      child: Text(
                        'ATIVOS',
                        style: AppTypography.overline.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),

                  SliverList.builder(
                    itemCount: investments.length,
                    itemBuilder: (ctx, i) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pageHPadding,
                        vertical: AppSpacing.xs,
                      ),
                      child: _InvestmentTile(
                        investment: investments[i],
                        index: i,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.addInvestment),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo ativo'),
      ),
    );
  }
}

class _AllocationChart extends StatelessWidget {
  const _AllocationChart({required this.investments});

  final List<InvestmentModel> investments;

  @override
  Widget build(BuildContext context) {
    final total =
        investments.fold(0.0, (s, i) => s + i.currentValue);

    // Group by type
    final byType = <InvestmentType, double>{};
    for (final inv in investments) {
      byType[inv.type] = (byType[inv.type] ?? 0) + inv.currentValue;
    }

    final sections = byType.entries.toList().asMap().entries.map((e) {
      final idx = e.key;
      final entry = e.value;
      final pct = total > 0 ? entry.value / total * 100 : 0.0;
      final color = AppColors.chartPalette[idx % AppColors.chartPalette.length];

      return PieChartSectionData(
        value: entry.value,
        title: '${pct.toStringAsFixed(0)}%',
        color: color,
        radius: 60,
        titleStyle: AppTypography.caption.copyWith(color: Colors.white),
      );
    }).toList();

    return Row(
      children: [
        SizedBox(
          width: 160,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 30,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: byType.entries.toList().asMap().entries.map((e) {
              final idx = e.key;
              final entry = e.value;
              final color =
                  AppColors.chartPalette[idx % AppColors.chartPalette.length];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
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
                        entry.key.label,
                        style: AppTypography.caption.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      entry.value.brlCompact,
                      style: AppTypography.caption.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _InvestmentTile extends StatelessWidget {
  const _InvestmentTile({required this.investment, required this.index});

  final InvestmentModel investment;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isProfitable = investment.profitLoss >= 0;
    final color = AppColors.chartPalette[index % AppColors.chartPalette.length];

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                investment.ticker.substring(0, investment.ticker.length.clamp(0, 4)),
                style: AppTypography.labelSmall.copyWith(color: color),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  investment.ticker,
                  style: AppTypography.labelLarge.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                Text(
                  investment.type.label,
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
                investment.currentValue.brlCompact,
                style: AppTypography.numericSmall.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isProfitable
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color: isProfitable ? AppColors.income : AppColors.expense,
                    size: 12,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${isProfitable ? '+' : ''}${(investment.profitLossPercent * 100).toStringAsFixed(2)}%',
                    style: AppTypography.caption.copyWith(
                      color: isProfitable ? AppColors.income : AppColors.expense,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn()
        .slideX(begin: 0.05);
  }
}

class AddInvestmentPage extends StatelessWidget {
  const AddInvestmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo investimento'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: const Center(child: Text('Formulário de investimento')),
    );
  }
}
