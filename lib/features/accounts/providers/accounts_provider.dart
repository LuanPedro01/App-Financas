import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:financeiro/core/services/database_service.dart';
import 'package:financeiro/features/accounts/data/models/account_model.dart';
import 'package:financeiro/features/accounts/domain/entities/account.dart';

class AccountsNotifier extends StateNotifier<AsyncValue<List<Account>>> {
  AccountsNotifier() : super(const AsyncValue.loading()) {
    loadAll();
  }

  Isar get _db => DatabaseService.instance;

  Future<void> loadAll() async {
    state = const AsyncValue.loading();
    try {
      final models = await _db.accountModels
          .where()
          .filter()
          .isActiveEqualTo(true)
          .findAll();
      state = AsyncValue.data(models.map(Account.fromModel).toList());
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> add(AccountModel model) async {
    await _db.writeTxn(() => _db.accountModels.put(model));
    await loadAll();
  }

  Future<void> update(AccountModel model) async {
    model.updatedAt = DateTime.now();
    await _db.writeTxn(() => _db.accountModels.put(model));
    await loadAll();
  }

  Future<void> delete(int id) async {
    await _db.writeTxn(() => _db.accountModels.delete(id));
    await loadAll();
  }

  Future<void> updateBalance(int id, double delta) async {
    final model = await _db.accountModels.get(id);
    if (model == null) return;
    model.balance += delta;
    model.updatedAt = DateTime.now();
    await _db.writeTxn(() => _db.accountModels.put(model));
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
