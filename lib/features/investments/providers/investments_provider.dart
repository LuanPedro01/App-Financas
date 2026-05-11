import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financeiro/core/services/database_service.dart';
import 'package:financeiro/features/investments/data/models/investment_model.dart';

class InvestmentsNotifier
    extends StateNotifier<AsyncValue<List<InvestmentModel>>> {
  InvestmentsNotifier() : super(const AsyncValue.loading()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = const AsyncValue.loading();
    try {
      final models = await DatabaseService.getInvestments();
      state = AsyncValue.data(models);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> add(InvestmentModel model) async {
    await DatabaseService.insertInvestment(model);
    await loadAll();
  }

  Future<void> update(InvestmentModel model) async {
    await DatabaseService.updateInvestment(model);
    await loadAll();
  }

  Future<void> delete(int id) async {
    await DatabaseService.deleteInvestment(id);
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
