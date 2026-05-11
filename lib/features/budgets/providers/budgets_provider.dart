import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financeiro/core/services/database_service.dart';
import 'package:financeiro/features/budgets/data/models/budget_model.dart';

class BudgetsNotifier extends StateNotifier<AsyncValue<List<BudgetModel>>> {
  BudgetsNotifier() : super(const AsyncValue.loading()) {
    loadCurrentMonth();
  }

  Future<void> loadCurrentMonth() async {
    final now = DateTime.now();
    await loadByMonth(now.month, now.year);
  }

  Future<void> loadByMonth(int month, int year) async {
    state = const AsyncValue.loading();
    try {
      final models =
          await DatabaseService.getBudgets(month: month, year: year);
      state = AsyncValue.data(models);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> add(BudgetModel model) async {
    await DatabaseService.insertBudget(model);
    await loadCurrentMonth();
  }

  Future<void> update(BudgetModel model) async {
    await DatabaseService.updateBudget(model);
    await loadCurrentMonth();
  }

  Future<void> delete(int id) async {
    await DatabaseService.deleteBudget(id);
    await loadCurrentMonth();
  }

  Future<void> updateSpent(String categoryId, double amount) async {
    await DatabaseService.updateBudgetSpent(
        categoryId, amount, DateTime.now(),);
    await loadCurrentMonth();
  }
}

final budgetsProvider =
    StateNotifierProvider<BudgetsNotifier, AsyncValue<List<BudgetModel>>>(
  (ref) => BudgetsNotifier(),
);
