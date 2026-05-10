import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:financeiro/core/services/database_service.dart';
import 'package:financeiro/features/investments/data/models/investment_model.dart';

class InvestmentsNotifier
    extends StateNotifier<AsyncValue<List<InvestmentModel>>> {
  InvestmentsNotifier() : super(const AsyncValue.loading()) {
    loadAll();
  }

  Isar get _db => DatabaseService.instance;

  Future<void> loadAll() async {
    state = const AsyncValue.loading();
    try {
      final models = await _db.investmentModels.where().findAll();
      state = AsyncValue.data(models);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> add(InvestmentModel model) async {
    await _db.writeTxn(() => _db.investmentModels.put(model));
    await loadAll();
  }

  Future<void> update(InvestmentModel model) async {
    await _db.writeTxn(() => _db.investmentModels.put(model));
    await loadAll();
  }

  Future<void> delete(int id) async {
    await _db.writeTxn(() => _db.investmentModels.delete(id));
    await loadAll();
  }
}

final investmentsProvider =
    StateNotifierProvider<InvestmentsNotifier, AsyncValue<List<InvestmentModel>>>(
  (ref) => InvestmentsNotifier(),
);

final portfolioTotalProvider = Provider<double>((ref) {
  final investments = ref.watch(investmentsProvider).valueOrNull ?? [];
  return investments.fold(0.0, (sum, i) => sum + i.currentValue);
});

final portfolioInvestedProvider = Provider<double>((ref) {
  final investments = ref.watch(investmentsProvider).valueOrNull ?? [];
  return investments.fold(0.0, (sum, i) => sum + i.totalInvested);
});

final portfolioProfitLossProvider = Provider<double>((ref) {
  return ref.watch(portfolioTotalProvider) -
      ref.watch(portfolioInvestedProvider);
});
