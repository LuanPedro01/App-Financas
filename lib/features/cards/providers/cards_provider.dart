import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:financeiro/core/services/database_service.dart';
import 'package:financeiro/features/cards/data/models/credit_card_model.dart';

class CardsNotifier
    extends StateNotifier<AsyncValue<List<CreditCardModel>>> {
  CardsNotifier() : super(const AsyncValue.loading()) {
    loadAll();
  }

  Isar get _db => DatabaseService.instance;

  Future<void> loadAll() async {
    state = const AsyncValue.loading();
    try {
      final models = await _db.creditCardModels
          .where()
          .filter()
          .isActiveEqualTo(true)
          .findAll();
      state = AsyncValue.data(models);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> add(CreditCardModel model) async {
    await _db.writeTxn(() => _db.creditCardModels.put(model));
    await loadAll();
  }

  Future<void> update(CreditCardModel model) async {
    model.updatedAt = DateTime.now();
    await _db.writeTxn(() => _db.creditCardModels.put(model));
    await loadAll();
  }

  Future<void> delete(int id) async {
    await _db.writeTxn(() => _db.creditCardModels.delete(id));
    await loadAll();
  }
}

final cardsProvider =
    StateNotifierProvider<CardsNotifier, AsyncValue<List<CreditCardModel>>>(
  (ref) => CardsNotifier(),
);

final totalInvoiceProvider = Provider<double>((ref) {
  final cards = ref.watch(cardsProvider).valueOrNull ?? [];
  return cards.fold(0.0, (sum, c) => sum + c.currentInvoiceAmount);
});
