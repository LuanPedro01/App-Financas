import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:financeiro/core/services/database_service.dart';
import 'package:financeiro/features/budgets/data/models/budget_model.dart';

class BudgetsNotifier
    extends StateNotifier<AsyncValue<List<BudgetModel>>> {
  BudgetsNotifier() : super(const AsyncValue.loading()) {
    loadCurrentMonth();
  }

  Isar get _db => DatabaseService.instance;

  Future<void> loadCurrentMonth() async {
    final now = DateTime.now();
    await loadByMonth(now.month, now.year);
  }

  Future<void> loadByMonth(int month, int year) async {
    state = const AsyncValue.loading();
    try {
      final models = await _db.budgetModels
          .where()
          .filter()
          .monthEqualTo(month)
          .yearEqualTo(year)
          .isActiveEqualTo(true)
          .findAll();
      state = AsyncValue.data(models);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> add(BudgetModel model) async {
    await _db.writeTxn(() => _db.budgetModels.put(model));
    await loadCurrentMonth();
  }

  Future<void> update(BudgetModel model) async {
    await _db.writeTxn(() => _db.budgetModels.put(model));
    await loadCurrentMonth();
  }

  Future<void> delete(int id) async {
    await _db.writeTxn(() => _db.budgetModels.delete(id));
    await loadCurrentMonth();
  }

  Future<void> updateSpent(String categoryId, double amount) async {
    final now = DateTime.now();
    final budgets = await _db.budgetModels
        .where()
        .filter()
        .categoryIdEqualTo(categoryId)
        .monthEqualTo(now.month)
        .yearEqualTo(now.year)
        .findAll();

    for (final b in budgets) {
      b.spent += amount;
      await _db.writeTxn(() => _db.budgetModels.put(b));
    }
    await loadCurrentMonth();
  }
}

final budgetsProvider =
    StateNotifierProvider<BudgetsNotifier, AsyncValue<List<BudgetModel>>>(
  (ref) => BudgetsNotifier(),
);
