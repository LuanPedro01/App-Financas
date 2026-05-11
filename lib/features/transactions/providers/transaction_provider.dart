import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financeiro/core/services/database_service.dart';
import 'package:financeiro/features/transactions/data/models/transaction_model.dart';
import 'package:financeiro/features/transactions/domain/entities/transaction.dart';
import 'package:financeiro/features/transactions/domain/enums/transaction_enums.dart';

class TransactionFilter {
  const TransactionFilter({
    this.startDate,
    this.endDate,
    this.type,
    this.categoryId,
    this.accountId,
    this.cardId,
    this.searchQuery,
    this.tags = const [],
    this.status,
    this.sortBy = 'date_desc',
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final TransactionType? type;
  final String? categoryId;
  final String? accountId;
  final String? cardId;
  final String? searchQuery;
  final List<String> tags;
  final TransactionStatus? status;
  final String sortBy;

  TransactionFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? categoryId,
    String? accountId,
    String? cardId,
    String? searchQuery,
    List<String>? tags,
    TransactionStatus? status,
    String? sortBy,
  }) =>
      TransactionFilter(
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        type: type ?? this.type,
        categoryId: categoryId ?? this.categoryId,
        accountId: accountId ?? this.accountId,
        cardId: cardId ?? this.cardId,
        searchQuery: searchQuery ?? this.searchQuery,
        tags: tags ?? this.tags,
        status: status ?? this.status,
        sortBy: sortBy ?? this.sortBy,
      );
}

class TransactionState {
  const TransactionState({
    this.transactions = const [],
    this.filteredTransactions = const [],
    this.isLoading = false,
    this.filter = const TransactionFilter(),
    this.error,
    this.undoTransaction,
  });

  final List<Transaction> transactions;
  final List<Transaction> filteredTransactions;
  final bool isLoading;
  final TransactionFilter filter;
  final String? error;
  final Transaction? undoTransaction;

  TransactionState copyWith({
    List<Transaction>? transactions,
    List<Transaction>? filteredTransactions,
    bool? isLoading,
    TransactionFilter? filter,
    String? error,
    Transaction? undoTransaction,
    bool clearError = false,
    bool clearUndo = false,
  }) =>
      TransactionState(
        transactions: transactions ?? this.transactions,
        filteredTransactions:
            filteredTransactions ?? this.filteredTransactions,
        isLoading: isLoading ?? this.isLoading,
        filter: filter ?? this.filter,
        error: clearError ? null : (error ?? this.error),
        undoTransaction:
            clearUndo ? null : (undoTransaction ?? this.undoTransaction),
      );
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  TransactionNotifier() : super(const TransactionState()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final models = await DatabaseService.getTransactions();
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
    await DatabaseService.insertTransaction(model);
    await loadAll();
  }

  Future<void> update(TransactionModel model) async {
    await DatabaseService.updateTransaction(model);
    await loadAll();
  }

  Future<void> delete(int id) async {
    final tx = state.transactions.where((t) => t.id == id).firstOrNull;
    await DatabaseService.deleteTransaction(id);
    state = state.copyWith(undoTransaction: tx);
    await loadAll();
  }

  Future<void> undoDelete() async {
    final tx = state.undoTransaction;
    if (tx == null) return;
    final model = _toModel(tx);
    await DatabaseService.insertTransaction(model);
    state = state.copyWith(clearUndo: true);
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
      List<Transaction> txs, TransactionFilter f,) {
    var result = txs.toList();

    if (f.startDate != null) {
      result = result
          .where((t) =>
              t.date.isAfter(f.startDate!.subtract(const Duration(seconds: 1)),),)
          .toList();
    }
    if (f.endDate != null) {
      result = result
          .where((t) =>
              t.date.isBefore(f.endDate!.add(const Duration(seconds: 1)),),)
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
              t.accountId == f.accountId || t.toAccountId == f.accountId,)
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
              (t.notes?.toLowerCase().contains(q) ?? false),)
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
        tags: t.tags.toList(),
        attachments: t.attachments.toList(),
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
