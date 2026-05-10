import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:financeiro/features/transactions/data/models/transaction_model.dart';
import 'package:financeiro/features/accounts/data/models/account_model.dart';
import 'package:financeiro/features/cards/data/models/credit_card_model.dart';
import 'package:financeiro/features/categories/data/models/category_model.dart';
import 'package:financeiro/features/budgets/data/models/budget_model.dart';
import 'package:financeiro/features/goals/data/models/goal_model.dart';
import 'package:financeiro/features/investments/data/models/investment_model.dart';
import 'package:financeiro/features/investments/data/models/investment_asset_model.dart';

class DatabaseService {
  DatabaseService._();

  static late Isar _isar;

  static Isar get instance => _isar;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        TransactionModelSchema,
        AccountModelSchema,
        CreditCardModelSchema,
        CategoryModelSchema,
        BudgetModelSchema,
        GoalModelSchema,
        InvestmentModelSchema,
        InvestmentAssetModelSchema,
      ],
      directory: dir.path,
      name: 'financeiro_db',
      inspector: false,
    );
  }

  static Future<void> clearAll() async {
    await _isar.writeTxn(() async {
      await _isar.clear();
    });
  }

  static Future<void> close() async {
    await _isar.close();
  }

  static Future<int> get sizeInBytes async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = await Future<dynamic>.value(
        '${dir.path}/financeiro_db.isar',
      );
      return 0;
    } catch (_) {
      return 0;
    }
  }
}
