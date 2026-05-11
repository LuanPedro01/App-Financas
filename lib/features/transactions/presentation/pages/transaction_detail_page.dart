import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:financeiro/app/router/route_paths.dart';
import 'package:financeiro/core/extensions/number_extensions.dart';
import 'package:financeiro/core/extensions/date_extensions.dart';
import 'package:financeiro/core/theme/app_colors.dart';
import 'package:financeiro/core/theme/app_spacing.dart';
import 'package:financeiro/core/theme/app_typography.dart';
import 'package:financeiro/features/transactions/providers/transaction_provider.dart';
import 'package:financeiro/features/transactions/domain/entities/transaction.dart';
import 'package:financeiro/shared/widgets/glass_card.dart';

class TransactionDetailPage extends ConsumerWidget {
  const TransactionDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txs = ref.watch(transactionProvider).transactions;
    final tx = txs.where((t) => t.id.toString() == id).firstOrNull;

    if (tx == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Transação não encontrada')),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final amountColor = tx.isIncome
        ? AppColors.income
        : tx.isTransfer
            ? AppColors.transfer
            : AppColors.expense;
    final prefix = tx.isIncome ? '+' : tx.isTransfer ? '' : '-';

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Detalhe'),
        actions: [
          IconButton(
            onPressed: () => context.push(
              RoutePaths.editTransactionPath(id),
            ),
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            onPressed: () => _confirmDelete(context, ref, tx),
            icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            // ─── Hero Amount ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.xl3,
                horizontal: AppSpacing.pageHPadding,
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: amountColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      tx.isIncome
                          ? Icons.arrow_downward_rounded
                          : tx.isTransfer
                              ? Icons.swap_horiz_rounded
                              : Icons.arrow_upward_rounded,
                      color: amountColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    '$prefix${tx.amount.brl}',
                    style: AppTypography.numericDisplay.copyWith(
                      color: amountColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    tx.title,
                    style: AppTypography.h5.copyWith(
                      color: scheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    tx.date.formattedLong,
                    style: AppTypography.bodySmall.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.1),

            // ─── Details Card ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHPadding,),
              child: AppCard(
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.category_outlined,
                      label: 'Categoria',
                      value: tx.categoryName ?? 'Sem categoria',
                    ),
                    const Divider(),
                    _DetailRow(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Conta',
                      value: tx.accountName ?? 'Sem conta',
                    ),
                    if (tx.cardName != null) ...[
                      const Divider(),
                      _DetailRow(
                        icon: Icons.credit_card_outlined,
                        label: 'Cartão',
                        value: tx.cardName!,
                      ),
                    ],
                    const Divider(),
                    _DetailRow(
                      icon: Icons.payment_outlined,
                      label: 'Pagamento',
                      value: tx.paymentMethod.label,
                    ),
                    const Divider(),
                    _DetailRow(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Status',
                      value: tx.status.label,
                      valueColor: tx.isPending
                          ? AppColors.warning500
                          : AppColors.success500,
                    ),
                    if (tx.isInstallment) ...[
                      const Divider(),
                      _DetailRow(
                        icon: Icons.format_list_numbered_rounded,
                        label: 'Parcela',
                        value: tx.installmentLabel,
                      ),
                    ],
                    if (tx.isRecurring) ...[
                      const Divider(),
                      _DetailRow(
                        icon: Icons.repeat_rounded,
                        label: 'Recorrência',
                        value: tx.recurrenceType.label,
                      ),
                    ],
                    if (tx.notes != null) ...[
                      const Divider(),
                      _DetailRow(
                        icon: Icons.notes_rounded,
                        label: 'Observações',
                        value: tx.notes!,
                      ),
                    ],
                  ],
                ),
              ),
            ).animate(delay: const Duration(milliseconds: 100)).fadeIn(),

            if (tx.tags.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHPadding,),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tags',
                      style: AppTypography.labelMedium.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: tx.tags
                          .map((tag) => Chip(label: Text(tag)))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Transaction tx) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir transação'),
        content: Text('Deseja excluir "${tx.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(transactionProvider.notifier).delete(tx.id);
              context.pop();
            },
            child: Text(
              'Excluir',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.labelMedium.copyWith(
              color: valueColor ?? scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
