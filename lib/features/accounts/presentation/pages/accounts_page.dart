import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:financeiro/app/router/route_paths.dart';
import 'package:financeiro/core/extensions/number_extensions.dart';
import 'package:financeiro/core/theme/app_colors.dart';
import 'package:financeiro/core/theme/app_spacing.dart';
import 'package:financeiro/core/theme/app_typography.dart';
import 'package:financeiro/features/accounts/providers/accounts_provider.dart';
import 'package:financeiro/features/accounts/domain/entities/account.dart';
import 'package:financeiro/features/accounts/data/models/account_model.dart';
import 'package:financeiro/shared/widgets/empty_state.dart';
import 'package:financeiro/shared/widgets/glass_card.dart';
import 'package:financeiro/shared/widgets/amount_display.dart';

class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final totalBalance = ref.watch(totalBalanceProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contas'),
        actions: [
          IconButton(
            onPressed: () => context.push(RoutePaths.addAccount),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (accounts) => accounts.isEmpty
            ? EmptyAccounts(
                onAdd: () => context.push(RoutePaths.addAccount),
              )
            : CustomScrollView(
                slivers: [
                  // Total Balance Summary
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.pageHPadding),
                      child: AppCard(
                        gradient: AppColors.darkCardGradient,
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Patrimônio total',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.dark200,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                AmountDisplay(
                                  amount: totalBalance,
                                  style: AppTypography.numericLarge.copyWith(
                                    color: AppColors.dark50,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: AppColors.brandGradient,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.account_balance_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().slideY(begin: 0.1),
                    ),
                  ),

                  // Group by type
                  for (final type in AccountType.values) ...[
                    if (accounts.any((a) => a.type == type)) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.pageHPadding,
                            AppSpacing.xl,
                            AppSpacing.pageHPadding,
                            AppSpacing.sm,
                          ),
                          child: Text(
                            type.label,
                            style: AppTypography.overline.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      SliverList.builder(
                        itemCount:
                            accounts.where((a) => a.type == type).length,
                        itemBuilder: (ctx, i) {
                          final list =
                              accounts.where((a) => a.type == type).toList();
                          final account = list[i];
                          return _AccountTile(
                            account: account,
                            index: i,
                          );
                        },
                      ),
                    ],
                  ],

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.addAccount),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova conta'),
      ),
    );
  }
}

class _AccountTile extends ConsumerWidget {
  const _AccountTile({required this.account, required this.index});

  final Account account;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final color = Color(account.color);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHPadding,
        vertical: AppSpacing.xs,
      ),
      child: AppCard(
        onTap: () => context.push(
          RoutePaths.accountDetailPath(account.id.toString()),
        ),
        child: Row(
          children: [
            Container(
              width: AppSpacing.avatarSize,
              height: AppSpacing.avatarSize,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppSpacing.cardSmallRadius),
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: AppTypography.labelLarge.copyWith(
                      color: scheme.onBackground,
                    ),
                  ),
                  if (account.bankName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      account.bankName!,
                      style: AppTypography.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AmountDisplay(
              amount: account.balance,
              style: AppTypography.numericSmall.copyWith(
                color: account.balance >= 0
                    ? AppColors.income
                    : AppColors.expense,
              ),
            ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: index * 60))
          .fadeIn()
          .slideX(begin: 0.05),
    );
  }
}

// ─── Add Account Page stub ────────────────────────────────────────────────────
class AddAccountPage extends StatelessWidget {
  const AddAccountPage({super.key, this.editId});
  final String? editId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editId != null ? 'Editar conta' : 'Nova conta'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: const Center(child: Text('Formulário de conta')),
    );
  }
}

// ─── Account Detail Page ──────────────────────────────────────────────────────
class AccountDetailPage extends StatelessWidget {
  const AccountDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da conta')),
      body: const Center(child: Text('Detalhes da conta')),
    );
  }
}
