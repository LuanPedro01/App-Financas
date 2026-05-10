import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:financeiro/core/extensions/number_extensions.dart';
import 'package:financeiro/core/extensions/date_extensions.dart';
import 'package:financeiro/core/theme/app_colors.dart';
import 'package:financeiro/core/theme/app_spacing.dart';
import 'package:financeiro/core/theme/app_typography.dart';
import 'package:financeiro/features/transactions/domain/entities/transaction.dart';
import 'package:financeiro/features/transactions/domain/enums/transaction_enums.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onSwipeDelete,
    this.onSwipeEdit,
    this.showDate = true,
    this.animate = true,
    this.animationIndex = 0,
  });

  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onSwipeDelete;
  final VoidCallback? onSwipeEdit;
  final bool showDate;
  final bool animate;
  final int animationIndex;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget tile = _buildTile(context, scheme);

    if (onSwipeDelete != null || onSwipeEdit != null) {
      tile = Dismissible(
        key: ValueKey('tx_${transaction.id}'),
        background: _buildSwipeBackground(
          context,
          alignment: Alignment.centerLeft,
          color: AppColors.info500,
          icon: Icons.edit_rounded,
          label: 'Editar',
        ),
        secondaryBackground: _buildSwipeBackground(
          context,
          alignment: Alignment.centerRight,
          color: AppColors.error500,
          icon: Icons.delete_rounded,
          label: 'Excluir',
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            onSwipeEdit?.call();
            return false;
          }
          return true;
        },
        onDismissed: (_) => onSwipeDelete?.call(),
        child: tile,
      );
    }

    if (animate) {
      tile = tile
          .animate(delay: Duration(milliseconds: animationIndex * 50))
          .fadeIn(duration: const Duration(milliseconds: 300))
          .slideX(
            begin: 0.05,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
    }

    return tile;
  }

  Widget _buildTile(BuildContext context, ColorScheme scheme) {
    final t = transaction;
    final isIncome = t.type == TransactionType.income;
    final isTransfer = t.type == TransactionType.transfer;
    final amountColor = isIncome
        ? AppColors.income
        : isTransfer
            ? AppColors.transfer
            : AppColors.expense;
    final amountPrefix = isIncome ? '+' : isTransfer ? '' : '-';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHPadding,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            _CategoryIcon(
              icon: t.categoryIcon ?? _defaultIcon(t.type),
              color: t.categoryColor != null
                  ? Color(t.categoryColor!)
                  : amountColor,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.title,
                          style: AppTypography.labelLarge.copyWith(
                            color: scheme.onBackground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (t.isInstallment) ...[
                        const SizedBox(width: AppSpacing.xs),
                        _InstallmentBadge(label: t.installmentLabel),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs2),
                  Row(
                    children: [
                      if (t.categoryName != null)
                        Text(
                          t.categoryName!,
                          style: AppTypography.caption.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      if (t.categoryName != null && showDate)
                        Text(
                          ' • ',
                          style: AppTypography.caption.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      if (showDate)
                        Text(
                          t.date.relativeShort,
                          style: AppTypography.caption.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$amountPrefix${t.amount.brl}',
                  style: AppTypography.numericSmall.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (t.isPending) ...[
                  const SizedBox(height: AppSpacing.xs2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning500.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Pendente',
                      style: AppTypography.overline.copyWith(
                        color: AppColors.warning500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(
    BuildContext context, {
    required AlignmentGeometry alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      color: color.withOpacity(0.15),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.xs2),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  String _defaultIcon(TransactionType type) {
    return switch (type) {
      TransactionType.income => 'arrow_downward',
      TransactionType.expense => 'arrow_upward',
      TransactionType.transfer => 'swap_horiz',
    };
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.icon, required this.color});

  final String icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.avatarSize,
      height: AppSpacing.avatarSize,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSpacing.cardSmallRadius),
      ),
      child: Center(
        child: Icon(
          _iconData(icon),
          color: color,
          size: AppSpacing.iconSize - 2,
        ),
      ),
    );
  }

  IconData _iconData(String name) {
    return switch (name) {
      'food' || 'restaurant' => Icons.restaurant_rounded,
      'transport' || 'car' => Icons.directions_car_rounded,
      'health' || 'medical' => Icons.favorite_rounded,
      'education' => Icons.school_rounded,
      'entertainment' => Icons.movie_rounded,
      'home' || 'house' => Icons.home_rounded,
      'shopping' => Icons.shopping_bag_rounded,
      'travel' => Icons.flight_rounded,
      'investment' => Icons.trending_up_rounded,
      'income' || 'salary' => Icons.work_rounded,
      'arrow_downward' => Icons.arrow_downward_rounded,
      'arrow_upward' => Icons.arrow_upward_rounded,
      'swap_horiz' => Icons.swap_horiz_rounded,
      _ => Icons.attach_money_rounded,
    };
  }
}

class _InstallmentBadge extends StatelessWidget {
  const _InstallmentBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.brand500.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTypography.overline.copyWith(
          color: AppColors.brand500,
        ),
      ),
    );
  }
}

class TransactionGroupHeader extends StatelessWidget {
  const TransactionGroupHeader({
    super.key,
    required this.label,
    required this.total,
  });

  final String label;
  final double total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isPositive = total >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.overline.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          Text(
            isPositive ? '+${total.brl}' : total.brl,
            style: AppTypography.labelSmall.copyWith(
              color: isPositive ? AppColors.income : AppColors.expense,
            ),
          ),
        ],
      ),
    );
  }
}
