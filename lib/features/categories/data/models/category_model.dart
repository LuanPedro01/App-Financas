import 'package:isar/isar.dart';
import 'package:financeiro/features/transactions/domain/enums/transaction_enums.dart';

part 'category_model.g.dart';

@collection
class CategoryModel {
  CategoryModel({
    required this.id,
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

  Id id;
  String name;
  String icon;
  int color;

  @enumerated
  TransactionType type;

  int? parentId;
  bool isSystem;
  bool isActive;
  int sortOrder;
  DateTime createdAt;
}
