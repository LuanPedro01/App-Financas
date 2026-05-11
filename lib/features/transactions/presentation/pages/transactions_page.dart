import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:financeiro/app/router/route_paths.dart';
import 'package:financeiro/core/extensions/date_extensions.dart';
import 'package:financeiro/core/theme/app_spacing.dart';
import 'package:financeiro/core/theme/app_typography.dart';
import 'package:financeiro/features/transactions/providers/transaction_provider.dart';
import 'package:financeiro/features/transactions/domain/entities/transaction.dart';
import 'package:financeiro/features/transactions/domain/enums/transaction_enums.dart';
import 'package:financeiro/shared/widgets/transaction_tile.dart';
import 'package:financeiro/shared/widgets/empty_state.dart';
import 'package:financeiro/shared/widgets/skeleton_loading.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChange() {
    if (_tabController.indexIsChanging) {
      final type = switch (_tabController.index) {
        1 => TransactionType.income,
        2 => TransactionType.expense,
        3 => TransactionType.transfer,
        _ => null,
      };
      final current = ref.read(transactionProvider).filter;
      ref.read(transactionProvider.notifier).applyFilter(
            current.copyWith(type: type),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final txState = ref.watch(transactionProvider);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            title: _showSearch
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: AppTypography.bodyMedium.copyWith(
                      color: scheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Buscar transações...',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (q) {
                      final f = ref.read(transactionProvider).filter;
                      ref
                          .read(transactionProvider.notifier)
                          .applyFilter(f.copyWith(searchQuery: q));
                    },
                  )
                : const Text('Transações'),
            floating: true,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(
                  _showSearch ? Icons.close_rounded : Icons.search_rounded,
                ),
                onPressed: () {
                  setState(() => _showSearch = !_showSearch);
                  if (!_showSearch) {
                    _searchController.clear();
                    final f = ref.read(transactionProvider).filter;
                    ref.read(transactionProvider.notifier).applyFilter(
                          f.copyWith(searchQuery: null),
                        );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: () => _showFilterSheet(context),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Todos'),
                Tab(text: 'Receitas'),
                Tab(text: 'Despesas'),
                Tab(text: 'Transf.'),
              ],
            ),
          ),
        ],
        body: txState.isLoading
            ? const TransactionSkeleton(count: 8)
            : txState.filteredTransactions.isEmpty
                ? EmptyTransactions(
                    onAdd: () => context.push(RoutePaths.addTransaction),
                  )
                : _TransactionsList(
                    transactions: txState.filteredTransactions,
                  ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _FilterSheet(),
    );
  }
}

// ─── Grouped list ─────────────────────────────────────────────────────────────
class _TransactionsList extends ConsumerWidget {
  const _TransactionsList({required this.transactions});

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group by date
    final groups = <String, List<Transaction>>{};
    for (final tx in transactions) {
      final key = tx.date.relativeDisplay;
      groups.putIfAbsent(key, () => []).add(tx);
    }

    final keys = groups.keys.toList();
    int globalIndex = 0;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: keys.length,
      itemBuilder: (ctx, groupIdx) {
        final key = keys[groupIdx];
        final txs = groups[key]!;
        final groupTotal = txs.fold<double>(0, (sum, t) {
          return sum +
              (t.isIncome
                  ? t.amount
                  : t.isExpense
                      ? -t.amount
                      : 0);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TransactionGroupHeader(
              label: key,
              total: groupTotal,
            ),
            for (final tx in txs) ...[
              TransactionTile(
                key: ValueKey(tx.id),
                transaction: tx,
                onTap: () => ctx.push(
                  RoutePaths.transactionDetailPath(tx.id.toString()),
                ),
                onSwipeEdit: () => ctx.push(
                  RoutePaths.editTransactionPath(tx.id.toString()),
                ),
                onSwipeDelete: () =>
                    ref.read(transactionProvider.notifier).delete(tx.id),
                animationIndex: globalIndex++,
              ),
            ],
          ],
        );
      },
    );
  }
}

// ─── Filter Sheet ─────────────────────────────────────────────────────────────
class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet();

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late TransactionFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = ref.read(transactionProvider).filter;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        padding: AppSpacing.bottomSheetInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Filtrar transações',
              style: AppTypography.h5.copyWith(color: scheme.onSurface),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Período',
              style: AppTypography.labelMedium.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(context, isStart: true),
                    icon: const Icon(Icons.calendar_today_rounded, size: 16),
                    label: Text(
                      _filter.startDate?.formattedShort ?? 'Início',
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(context, isStart: false),
                    icon: const Icon(Icons.calendar_today_rounded, size: 16),
                    label: Text(
                      _filter.endDate?.formattedShort ?? 'Fim',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(transactionProvider.notifier).clearFilter();
                      Navigator.pop(context);
                    },
                    child: const Text('Limpar'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      ref
                          .read(transactionProvider.notifier)
                          .applyFilter(_filter);
                      Navigator.pop(context);
                    },
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, {required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _filter.startDate : _filter.endDate) ??
          DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _filter = isStart
            ? _filter.copyWith(startDate: picked)
            : _filter.copyWith(endDate: picked);
      });
    }
  }
}
