class BudgetModel {
  BudgetModel({
    this.id = 0,
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

  int id;
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
  double get progress =>
      amount > 0 ? (spent / amount).clamp(0.0, 1.0) : 0.0;
  bool get isOverBudget => spent > amount;
  bool get isNearLimit => progress >= alertThreshold && !isOverBudget;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'amount': amount,
      'spent': spent,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'categoryColor': categoryColor,
      'month': month,
      'year': year,
      'isActive': isActive ? 1 : 0,
      'alertThreshold': alertThreshold,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
    if (id != 0) map['id'] = id;
    return map;
  }

  factory BudgetModel.fromMap(Map<String, dynamic> m) => BudgetModel(
        id: m['id'] as int,
        name: m['name'] as String,
        amount: (m['amount'] as num).toDouble(),
        spent: (m['spent'] as num? ?? 0).toDouble(),
        categoryId: m['categoryId'] as String,
        categoryName: m['categoryName'] as String,
        categoryIcon: m['categoryIcon'] as String,
        categoryColor: m['categoryColor'] as int,
        month: m['month'] as int,
        year: m['year'] as int,
        isActive: (m['isActive'] as int? ?? 1) == 1,
        alertThreshold: (m['alertThreshold'] as num? ?? 0.75).toDouble(),
        notes: m['notes'] as String?,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );
}
