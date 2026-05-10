import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financeiro/core/extensions/number_extensions.dart';
import 'package:financeiro/core/theme/app_typography.dart';
import 'package:financeiro/features/settings/providers/settings_provider.dart';

class AmountDisplay extends ConsumerWidget {
  const AmountDisplay({
    super.key,
    required this.amount,
    this.style,
    this.color,
    this.showSign = false,
    this.isIncome,
    this.compact = false,
    this.obfuscateChar = '•••••',
  });

  final double amount;
  final TextStyle? style;
  final Color? color;
  final bool showSign;
  final bool? isIncome;
  final bool compact;
  final String obfuscateChar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hideBalance = ref.watch(settingsProvider).hideBalance;

    String display;
    if (hideBalance) {
      display = 'R\$ $obfuscateChar';
    } else if (compact) {
      display = amount.brlCompact;
    } else {
      display = amount.brl;
    }

    if (showSign && !hideBalance) {
      if (amount > 0) display = '+$display';
    }

    return Text(
      display,
      style: style ?? AppTypography.numericLarge,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class BalanceTile extends StatelessWidget {
  const BalanceTile({
    super.key,
    required this.label,
    required this.amount,
    this.color,
    this.icon,
  });

  final String label;
  final double amount;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: color ?? scheme.onSurfaceVariant),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        AmountDisplay(
          amount: amount,
          style: AppTypography.numericMedium.copyWith(
            color: color ?? scheme.onBackground,
          ),
          color: color,
          compact: true,
        ),
      ],
    );
  }
}
