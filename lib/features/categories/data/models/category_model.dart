import 'package:financeiro/features/transactions/domain/enums/transaction_enums.dart';

class CategoryModel {
  CategoryModel({
    this.id = 0,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.createdAt,
    this.parentId,
    this.isSystem = false,
    this.isActive = true,
    this.sortOrder = 0,
  });

  int id;
  String name;
  String icon;
  int color;
  TransactionType type;
  int? parentId;
  bool isSystem;
  bool isActive;
  int sortOrder;
  DateTime createdAt;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'icon': icon,
      'color': color,
      'type': type.name,
      'parentId': parentId,
      'isSystem': isSystem ? 1 : 0,
      'isActive': isActive ? 1 : 0,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
    };
    if (id != 0) map['id'] = id;
    return map;
  }

  factory CategoryModel.fromMap(Map<String, dynamic> m) => CategoryModel(
        id: m['id'] as int,
        name: m['name'] as String,
        icon: m['icon'] as String,
        color: m['color'] as int,
        type: TransactionType.values.firstWhere(
          (e) => e.name == m['type'],
          orElse: () => TransactionType.expense,
        ),
        parentId: m['parentId'] as int?,
        isSystem: (m['isSystem'] as int?) == 1,
        isActive: (m['isActive'] as int? ?? 1) == 1,
        sortOrder: m['sortOrder'] as int? ?? 0,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );
}
