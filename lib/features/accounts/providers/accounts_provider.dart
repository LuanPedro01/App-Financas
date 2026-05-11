import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financeiro/core/services/database_service.dart';
import 'package:financeiro/features/accounts/data/models/account_model.dart';
import 'package:financeiro/features/accounts/domain/entities/account.dart';

class AccountsNotifier extends StateNotifier<AsyncValue<List<Account>>> {
  AccountsNotifier() : super(const AsyncValue.loading()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = const AsyncValue.loading();
    try {
      final models = await DatabaseService.getAccounts();
      state = AsyncValue.data(models.map(Account.fromModel).toList());
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> add(AccountModel model) async {
    await DatabaseService.insertAccount(model);
    await loadAll();
  }

  Future<void> update(AccountModel model) async {
    model.updatedAt = DateTime.now();
    await DatabaseService.updateAccount(model);
    await loadAll();
  }

  Future<void> delete(int id) async {
    await DatabaseService.deleteAccount(id);
    await loadAll();
  }

  Future<void> updateBalance(int id, double delta) async {
    await DatabaseService.updateAccountBalance(id, delta);
    await loadAll();
  }
}

final accountsProvider =
    StateNotifierProvider<AccountsNotifier, AsyncValue<List<Account>>>((ref) {
  return AccountsNotifier();
});

final totalBalanceProvider = Provider<double>((ref) {
  final accounts = ref.watch(accountsProvider).valueOrNull ?? [];
  return accounts
      .where((a) => a.includeInTotal)
      .fold(0.0, (sum, a) => sum + a.balance);
});
