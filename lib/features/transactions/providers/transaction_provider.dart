import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';
import 'package:financeiro/core/services/database_service.dart';
import 'package:financeiro/features/transactions/data/models/transaction_model.dart';
import 'package:financeiro/features/transactions/domain/entities/transaction.dart';
import 'package:financeiro/features/transactions/domain/enums/transaction_enums.dart';

part 'transaction_provider.freezed.dart';

@freezed
class TransactionFilter with _$TransactionFilter {
  const factory TransactionFilter({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? categoryId,
    String? accountId,
    String? cardId,
    String? searchQuery,
    @Default([]) List<String> tags,
    TransactionStatus? status,
    @Default('date_desc') String sortBy,
  }) = _TransactionFilter;
}

@freezed
class TransactionState with _$TransactionState {
  const factory TransactionState({
    @Default([]) List<Transaction> transactions,
    @Default([]) List<Transaction> filteredTransactions,
    @Default(false) bool isLoading,
    @Default(TransactionFilter()) TransactionFilter filter,
    String? error,
    Transaction? undoTransaction,
  }) = _TransactionState;
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  TransactionNotifier() : super(const TransactionState()) {
    loadAll();
  }

  Isar get _db => DatabaseService.instance;

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final models = await _db.transactionModels
          .where()
          .sortByDateDesc()
          .findAll();
      final transactions = models.map(Transaction.fromModel).toList();
      state = state.copyWith(
        transactions: transactions,
        filteredTransactions: _applyFilter(transactions, state.filter),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar transações: $e',
      );
    }
  }

  Future<void> add(TransactionModel model) async {
    await _db.writeTxn(() => _db.transactionModels.put(model));
    await loadAll();
  }

  Future<void> update(TransactionModel model) async {
    await _db.writeTxn(() => _db.transactionModels.put(model));
    await loadAll();
  }

  Future<void> delete(int id) async {
    final model = await _db.transactionModels.get(id);
    if (model == null) return;
    final tx = Transaction.fromModel(model);
    await _db.writeTxn(() => _db.transactionModels.delete(id));
    state = state.copyWith(undoTransaction: tx);
    await loadAll();
  }

  Future<void> undoDelete() async {
    final tx = state.undoTransaction;
    if (tx == null) return;
    final model = _toModel(tx);
    await _db.writeTxn(() => _db.transactionModels.put(model));
    state = state.copyWith(undoTransaction: null);
    await loadAll();
  }

  void applyFilter(TransactionFilter filter) {
    state = state.copyWith(
      filter: filter,
      filteredTransactions: _applyFilter(state.transactions, filter),
    );
  }

  void clearFilter() {
    const filter = TransactionFilter();
    state = state.copyWith(
      filter: filter,
      filteredTransactions: state.transactions,
    );
  }

  List<Transaction> _applyFilter(
    List<Transaction> txs,
    TransactionFilter f,
  ) {
    var result = txs.toList();

    if (f.startDate != null) {
      result = result
          .where((t) =>
              t.date.isAfter(f.startDate!.subtract(const Duration(seconds: 1))))
          .toList();
    }

    if (f.endDate != null) {
      result = result
          .where((t) =>
              t.date.isBefore(f.endDate!.add(const Duration(seconds: 1))))
          .toList();
    }

    if (f.type != null) {
      result = result.where((t) => t.type == f.type).toList();
    }

    if (f.categoryId != null) {
      result = result.where((t) => t.categoryId == f.categoryId).toList();
    }

    if (f.accountId != null) {
      result = result
          .where((t) =>
              t.accountId == f.accountId || t.toAccountId == f.accountId)
          .toList();
    }

    if (f.cardId != null) {
      result = result.where((t) => t.cardId == f.cardId).toList();
    }

    if (f.status != null) {
      result = result.where((t) => t.status == f.status).toList();
    }

    if (f.tags.isNotEmpty) {
      result = result
          .where((t) => f.tags.any((tag) => t.tags.contains(tag)))
          .toList();
    }

    if (f.searchQuery != null && f.searchQuery!.isNotEmpty) {
      final q = f.searchQuery!.toLowerCase();
      result = result
          .where((t) =>
              t.title.toLowerCase().contains(q) ||
              (t.categoryName?.toLowerCase().contains(q) ?? false) ||
              (t.notes?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    switch (f.sortBy) {
      case 'date_asc':
        result.sort((a, b) => a.date.compareTo(b.date));
      case 'amount_desc':
        result.sort((a, b) => b.amount.compareTo(a.amount));
      case 'amount_asc':
        result.sort((a, b) => a.amount.compareTo(b.amount));
      case 'title_asc':
        result.sort((a, b) => a.title.compareTo(b.title));
      default:
        result.sort((a, b) => b.date.compareTo(a.date));
    }

    return result;
  }

  TransactionModel _toModel(Transaction t) => TransactionModel(
        id: t.id,
        title: t.title,
        amount: t.amount,
        type: t.type,
        date: t.date,
        createdAt: t.createdAt,
        description: t.description,
        categoryId: t.categoryId,
        categoryName: t.categoryName,
        categoryIcon: t.categoryIcon,
        categoryColor: t.categoryColor,
        accountId: t.accountId,
        accountName: t.accountName,
        toAccountId: t.toAccountId,
        toAccountName: t.toAccountName,
        cardId: t.cardId,
        cardName: t.cardName,
        tags: t.tags,
        attachments: t.attachments,
        status: t.status,
        paymentMethod: t.paymentMethod,
        recurrenceType: t.recurrenceType,
        recurrenceGroupId: t.recurrenceGroupId,
        installmentNumber: t.installmentNumber,
        totalInstallments: t.totalInstallments,
        installmentGroupId: t.installmentGroupId,
        isFixed: t.isFixed,
        notes: t.notes,
        latitude: t.latitude,
        longitude: t.longitude,
        locationName: t.locationName,
        updatedAt: t.updatedAt,
      );
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  return TransactionNotifier();
});

// ─── Derived providers ────────────────────────────────────────────────────────
final currentMonthTransactionsProvider = Provider<List<Transaction>>((ref) {
  final txs = ref.watch(transactionProvider).transactions;
  final now = DateTime.now();
  return txs
      .where((t) => t.date.month == now.month && t.date.year == now.year)
      .toList();
});

final currentMonthIncomeProvider = Provider<double>((ref) {
  return ref
      .watch(currentMonthTransactionsProvider)
      .where((t) => t.type == TransactionType.income && t.isCompleted)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final currentMonthExpenseProvider = Provider<double>((ref) {
  return ref
      .watch(currentMonthTransactionsProvider)
      .where((t) => t.type == TransactionType.expense && t.isCompleted)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final recentTransactionsProvider = Provider<List<Transaction>>((ref) {
  final txs = ref.watch(transactionProvider).transactions;
  return txs.take(10).toList();
});
