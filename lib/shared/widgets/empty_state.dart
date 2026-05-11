import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:financeiro/core/theme/app_colors.dart';
import 'package:financeiro/core/theme/app_spacing.dart';
import 'package:financeiro/core/theme/app_typography.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
    this.actionLabel,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? action;
  final String? actionLabel;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color:
                    (iconColor ?? scheme.primary).withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppSpacing.cardRadius),
              ),
              child: Icon(
                icon,
                size: 36,
                color: iconColor ?? scheme.primary,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.elasticOut,
                )
                .fadeIn(),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              style: AppTypography.h5.copyWith(
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.center,
            )
                .animate(delay: const Duration(milliseconds: 100))
                .fadeIn()
                .slideY(begin: 0.3, duration: const Duration(milliseconds: 300)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: AppTypography.bodyMedium.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            )
                .animate(delay: const Duration(milliseconds: 150))
                .fadeIn()
                .slideY(begin: 0.3, duration: const Duration(milliseconds: 300)),
            if (action != null && actionLabel != null) ...[
              const SizedBox(height: AppSpacing.xl2),
              FilledButton.icon(
                onPressed: action,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
              )
                  .animate(delay: const Duration(milliseconds: 200))
                  .fadeIn()
                  .slideY(
                      begin: 0.3,
                      duration: const Duration(milliseconds: 300),),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyTransactions extends StatelessWidget {
  const EmptyTransactions({super.key, this.onAdd});

  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.receipt_long_rounded,
      title: 'Nenhuma transação',
      subtitle: 'Suas transações financeiras aparecerão aqui. Comece adicionando sua primeira.',
      action: onAdd,
      actionLabel: 'Adicionar transação',
    );
  }
}

class EmptyAccounts extends StatelessWidget {
  const EmptyAccounts({super.key, this.onAdd});

  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.account_balance_wallet_rounded,
      iconColor: AppColors.brand500,
      title: 'Nenhuma conta',
      subtitle: 'Adicione suas contas bancárias, carteiras e investimentos.',
      action: onAdd,
      actionLabel: 'Adicionar conta',
    );
  }
}

class EmptyGoals extends StatelessWidget {
  const EmptyGoals({super.key, this.onAdd});

  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.flag_rounded,
      iconColor: AppColors.accent500,
      title: 'Nenhuma meta',
      subtitle: 'Defina metas financeiras e acompanhe seu progresso.',
      action: onAdd,
      actionLabel: 'Criar meta',
    );
  }
}

class EmptyInvestments extends StatelessWidget {
  const EmptyInvestments({super.key, this.onAdd});

  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.trending_up_rounded,
      iconColor: AppColors.investment,
      title: 'Nenhum investimento',
      subtitle: 'Acompanhe sua carteira de investimentos aqui.',
      action: onAdd,
      actionLabel: 'Adicionar investimento',
    );
  }
}
