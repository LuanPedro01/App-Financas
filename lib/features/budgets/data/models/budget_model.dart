import 'package:isar/isar.dart';
import 'package:financeiro/features/transactions/domain/enums/transaction_enums.dart';

part 'budget_model.g.dart';

@collection
class BudgetModel {
  BudgetModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.month,
    required this.year,
    required this.createdAt,
    this.spent = 0.0,
    this.isActive = true,
    this.alertThreshold = 0.75,
    this.notes,
  });

  Id id;
  String name;
  double amount;
  double spent;
  String categoryId;
  String categoryName;
  String categoryIcon;
  int categoryColor;
  int month;
  int year;
  bool isActive;
  double alertThreshold;
  String? notes;
  DateTime createdAt;

  double get remaining => amount - spent;
  double get progress => amount > 0 ? (spent / amount).clamp(0.0, 1.0) : 0.0;
  bool get isOverBudget => spent > amount;
  bool get isNearLimit => progress >= alertThreshold && !isOverBudget;
}
