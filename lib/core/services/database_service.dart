import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
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

  static late Database _db;

  static Future<void> initialize() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'app_financas.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        description TEXT,
        categoryId TEXT,
        categoryName TEXT,
        categoryIcon TEXT,
        categoryColor INTEGER,
        accountId TEXT,
        accountName TEXT,
        toAccountId TEXT,
        toAccountName TEXT,
        cardId TEXT,
        cardName TEXT,
        tags TEXT,
        attachments TEXT,
        status TEXT NOT NULL,
        paymentMethod TEXT NOT NULL,
        recurrenceType TEXT NOT NULL,
        recurrenceGroupId TEXT,
        installmentNumber INTEGER,
        totalInstallments INTEGER,
        installmentGroupId TEXT,
        isFixed INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        latitude REAL,
        longitude REAL,
        locationName TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        balance REAL NOT NULL,
        initialBalance REAL NOT NULL DEFAULT 0,
        color INTEGER NOT NULL,
        icon TEXT NOT NULL,
        bankName TEXT,
        bankLogo TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        includeInTotal INTEGER NOT NULL DEFAULT 1,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE credit_cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        brand TEXT NOT NULL,
        "limit" REAL NOT NULL,
        currentInvoiceAmount REAL NOT NULL DEFAULT 0,
        availableLimit REAL NOT NULL DEFAULT 0,
        cashbackPercent REAL NOT NULL DEFAULT 0,
        closingDay INTEGER NOT NULL,
        dueDay INTEGER NOT NULL,
        color INTEGER NOT NULL,
        lastFourDigits TEXT,
        accountId TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color INTEGER NOT NULL,
        type TEXT NOT NULL,
        parentId INTEGER,
        isSystem INTEGER NOT NULL DEFAULT 0,
        isActive INTEGER NOT NULL DEFAULT 1,
        sortOrder INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        spent REAL NOT NULL DEFAULT 0,
        categoryId TEXT NOT NULL,
        categoryName TEXT NOT NULL,
        categoryIcon TEXT NOT NULL,
        categoryColor INTEGER NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        alertThreshold REAL NOT NULL DEFAULT 0.75,
        notes TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        targetAmount REAL NOT NULL,
        currentAmount REAL NOT NULL DEFAULT 0,
        monthlyContribution REAL NOT NULL DEFAULT 0,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        color INTEGER NOT NULL,
        icon TEXT NOT NULL,
        targetDate TEXT,
        accountId TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE investments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        ticker TEXT NOT NULL,
        type TEXT NOT NULL,
        quantity REAL NOT NULL,
        avgPrice REAL NOT NULL,
        currentPrice REAL NOT NULL,
        dividendsReceived REAL NOT NULL DEFAULT 0,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE investment_assets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        investmentId INTEGER NOT NULL,
        date TEXT NOT NULL,
        quantity REAL NOT NULL,
        price REAL NOT NULL,
        type TEXT NOT NULL,
        fees REAL NOT NULL DEFAULT 0,
        notes TEXT
      )
    ''');
  }

  // ─── Transactions ─────────────────────────────────────────────────────────

  static Future<List<TransactionModel>> getTransactions() async {
    final rows = await _db.query('transactions', orderBy: 'date DESC');
    return rows.map(TransactionModel.fromMap).toList();
  }

  static Future<int> insertTransaction(TransactionModel m) async {
    return _db.insert('transactions', m.toMap());
  }

  static Future<void> updateTransaction(TransactionModel m) async {
    await _db.update(
      'transactions',
      m.toMap(),
      where: 'id = ?',
      whereArgs: [m.id],
    );
  }

  static Future<void> deleteTransaction(int id) async {
    await _db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Accounts ─────────────────────────────────────────────────────────────

  static Future<List<AccountModel>> getAccounts() async {
    final rows = await _db.query(
      'accounts',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return rows.map(AccountModel.fromMap).toList();
  }

  static Future<int> insertAccount(AccountModel m) async {
    return _db.insert('accounts', m.toMap());
  }

  static Future<void> updateAccount(AccountModel m) async {
    await _db.update(
      'accounts',
      m.toMap(),
      where: 'id = ?',
      whereArgs: [m.id],
    );
  }

  static Future<void> deleteAccount(int id) async {
    await _db.update(
      'accounts',
      {'isActive': 0, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> updateAccountBalance(int id, double delta) async {
    await _db.rawUpdate(
      'UPDATE accounts SET balance = balance + ?, updatedAt = ? WHERE id = ?',
      [delta, DateTime.now().toIso8601String(), id],
    );
  }

  // ─── Credit Cards ──────────────────────────────────────────────────────────

  static Future<List<CreditCardModel>> getCreditCards() async {
    final rows = await _db.query(
      'credit_cards',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return rows.map(CreditCardModel.fromMap).toList();
  }

  static Future<int> insertCreditCard(CreditCardModel m) async {
    return _db.insert('credit_cards', m.toMap());
  }

  static Future<void> updateCreditCard(CreditCardModel m) async {
    await _db.update(
      'credit_cards',
      m.toMap(),
      where: 'id = ?',
      whereArgs: [m.id],
    );
  }

  static Future<void> deleteCreditCard(int id) async {
    await _db.update(
      'credit_cards',
      {'isActive': 0, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── Categories ───────────────────────────────────────────────────────────

  static Future<List<CategoryModel>> getCategories() async {
    final rows = await _db.query(
      'categories',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'sortOrder ASC, name ASC',
    );
    return rows.map(CategoryModel.fromMap).toList();
  }

  static Future<int> insertCategory(CategoryModel m) async {
    return _db.insert('categories', m.toMap());
  }

  static Future<void> updateCategory(CategoryModel m) async {
    await _db.update(
      'categories',
      m.toMap(),
      where: 'id = ?',
      whereArgs: [m.id],
    );
  }

  static Future<void> deleteCategory(int id) async {
    await _db.update(
      'categories',
      {'isActive': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── Budgets ──────────────────────────────────────────────────────────────

  static Future<List<BudgetModel>> getBudgets({
    required int month,
    required int year,
  }) async {
    final rows = await _db.query(
      'budgets',
      where: 'month = ? AND year = ? AND isActive = ?',
      whereArgs: [month, year, 1],
      orderBy: 'name ASC',
    );
    return rows.map(BudgetModel.fromMap).toList();
  }

  static Future<int> insertBudget(BudgetModel m) async {
    return _db.insert('budgets', m.toMap());
  }

  static Future<void> updateBudget(BudgetModel m) async {
    await _db.update(
      'budgets',
      m.toMap(),
      where: 'id = ?',
      whereArgs: [m.id],
    );
  }

  static Future<void> deleteBudget(int id) async {
    await _db.update(
      'budgets',
      {'isActive': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> updateBudgetSpent(
      String categoryId, double amount, DateTime now,) async {
    await _db.rawUpdate(
      'UPDATE budgets SET spent = spent + ? WHERE categoryId = ? AND month = ? AND year = ? AND isActive = 1',
      [amount, categoryId, now.month, now.year],
    );
  }

  // ─── Goals ────────────────────────────────────────────────────────────────

  static Future<List<GoalModel>> getActiveGoals() async {
    final rows = await _db.query(
      'goals',
      where: 'status = ? OR status = ?',
      whereArgs: ['active', 'paused'],
      orderBy: 'createdAt DESC',
    );
    return rows.map(GoalModel.fromMap).toList();
  }

  static Future<int> insertGoal(GoalModel m) async {
    return _db.insert('goals', m.toMap());
  }

  static Future<void> updateGoal(GoalModel m) async {
    await _db.update(
      'goals',
      m.toMap(),
      where: 'id = ?',
      whereArgs: [m.id],
    );
  }

  static Future<void> deleteGoal(int id) async {
    await _db.update(
      'goals',
      {'status': 'cancelled', 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> contributeToGoal(int id, double amount) async {
    final rows = await _db.query('goals', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return;
    final goal = GoalModel.fromMap(rows.first);
    goal.currentAmount += amount;
    goal.updatedAt = DateTime.now();
    if (goal.currentAmount >= goal.targetAmount) {
      goal.status = GoalStatus.completed;
    }
    await _db.update('goals', goal.toMap(), where: 'id = ?', whereArgs: [id]);
  }

  // ─── Investments ──────────────────────────────────────────────────────────

  static Future<List<InvestmentModel>> getInvestments() async {
    final rows = await _db.query('investments', orderBy: 'name ASC');
    return rows.map(InvestmentModel.fromMap).toList();
  }

  static Future<int> insertInvestment(InvestmentModel m) async {
    return _db.insert('investments', m.toMap());
  }

  static Future<void> updateInvestment(InvestmentModel m) async {
    await _db.update(
      'investments',
      m.toMap(),
      where: 'id = ?',
      whereArgs: [m.id],
    );
  }

  static Future<void> deleteInvestment(int id) async {
    await _db.delete('investments', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Investment Assets ────────────────────────────────────────────────────

  static Future<List<InvestmentAssetModel>> getInvestmentAssets(
      int investmentId,) async {
    final rows = await _db.query(
      'investment_assets',
      where: 'investmentId = ?',
      whereArgs: [investmentId],
      orderBy: 'date DESC',
    );
    return rows.map(InvestmentAssetModel.fromMap).toList();
  }

  static Future<int> insertInvestmentAsset(InvestmentAssetModel m) async {
    return _db.insert('investment_assets', m.toMap());
  }

  // ─── Utilities ────────────────────────────────────────────────────────────

  static Future<void> clearAll() async {
    final batch = _db.batch();
    for (final table in [
      'transactions',
      'accounts',
      'credit_cards',
      'categories',
      'budgets',
      'goals',
      'investments',
      'investment_assets',
    ]) {
      batch.delete(table);
    }
    await batch.commit();
  }

  static Future<void> close() async => _db.close();
}
