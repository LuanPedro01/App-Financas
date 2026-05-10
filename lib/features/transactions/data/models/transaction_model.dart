import 'package:isar/isar.dart';
import 'package:financeiro/features/transactions/domain/enums/transaction_enums.dart';

part 'transaction_model.g.dart';

@collection
class TransactionModel {
  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    required this.createdAt,
    this.description,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.accountId,
    this.accountName,
    this.toAccountId,
    this.toAccountName,
    this.cardId,
    this.cardName,
    this.tags = const [],
    this.attachments = const [],
    this.status = TransactionStatus.completed,
    this.paymentMethod = PaymentMethod.pix,
    this.recurrenceType = RecurrenceType.none,
    this.recurrenceGroupId,
    this.installmentNumber,
    this.totalInstallments,
    this.installmentGroupId,
    this.isFixed = false,
    this.notes,
    this.latitude,
    this.longitude,
    this.locationName,
    this.updatedAt,
  });

  Id id;
  String title;
  double amount;

  @enumerated
  TransactionType type;

  DateTime date;
  DateTime createdAt;
  DateTime? updatedAt;

  String? description;
  String? categoryId;
  String? categoryName;
  String? categoryIcon;
  int? categoryColor;

  String? accountId;
  String? accountName;
  String? toAccountId;
  String? toAccountName;
  String? cardId;
  String? cardName;

  List<String> tags;
  List<String> attachments;

  @enumerated
  TransactionStatus status;

  @enumerated
  PaymentMethod paymentMethod;

  @enumerated
  RecurrenceType recurrenceType;

  String? recurrenceGroupId;
  int? installmentNumber;
  int? totalInstallments;
  String? installmentGroupId;
  bool isFixed;
  String? notes;
  double? latitude;
  double? longitude;
  String? locationName;
}
