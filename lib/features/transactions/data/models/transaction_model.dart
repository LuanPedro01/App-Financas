import 'dart:convert';
import 'package:financeiro/features/transactions/domain/enums/transaction_enums.dart';

class TransactionModel {
  TransactionModel({
    this.id = 0,
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

  int id;
  String title;
  double amount;
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
  TransactionStatus status;
  PaymentMethod paymentMethod;
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

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'amount': amount,
      'type': type.name,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'categoryColor': categoryColor,
      'accountId': accountId,
      'accountName': accountName,
      'toAccountId': toAccountId,
      'toAccountName': toAccountName,
      'cardId': cardId,
      'cardName': cardName,
      'tags': jsonEncode(tags),
      'attachments': jsonEncode(attachments),
      'status': status.name,
      'paymentMethod': paymentMethod.name,
      'recurrenceType': recurrenceType.name,
      'recurrenceGroupId': recurrenceGroupId,
      'installmentNumber': installmentNumber,
      'totalInstallments': totalInstallments,
      'installmentGroupId': installmentGroupId,
      'isFixed': isFixed ? 1 : 0,
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
    };
    if (id != 0) map['id'] = id;
    return map;
  }

  factory TransactionModel.fromMap(Map<String, dynamic> m) => TransactionModel(
        id: m['id'] as int,
        title: m['title'] as String,
        amount: (m['amount'] as num).toDouble(),
        type: TransactionType.values.firstWhere(
          (e) => e.name == m['type'],
          orElse: () => TransactionType.expense,
        ),
        date: DateTime.parse(m['date'] as String),
        createdAt: DateTime.parse(m['createdAt'] as String),
        updatedAt: m['updatedAt'] != null
            ? DateTime.tryParse(m['updatedAt'] as String)
            : null,
        description: m['description'] as String?,
        categoryId: m['categoryId'] as String?,
        categoryName: m['categoryName'] as String?,
        categoryIcon: m['categoryIcon'] as String?,
        categoryColor: m['categoryColor'] as int?,
        accountId: m['accountId'] as String?,
        accountName: m['accountName'] as String?,
        toAccountId: m['toAccountId'] as String?,
        toAccountName: m['toAccountName'] as String?,
        cardId: m['cardId'] as String?,
        cardName: m['cardName'] as String?,
        tags: m['tags'] != null
            ? List<String>.from(jsonDecode(m['tags'] as String) as List)
            : [],
        attachments: m['attachments'] != null
            ? List<String>.from(jsonDecode(m['attachments'] as String) as List)
            : [],
        status: TransactionStatus.values.firstWhere(
          (e) => e.name == m['status'],
          orElse: () => TransactionStatus.completed,
        ),
        paymentMethod: PaymentMethod.values.firstWhere(
          (e) => e.name == m['paymentMethod'],
          orElse: () => PaymentMethod.pix,
        ),
        recurrenceType: RecurrenceType.values.firstWhere(
          (e) => e.name == m['recurrenceType'],
          orElse: () => RecurrenceType.none,
        ),
        recurrenceGroupId: m['recurrenceGroupId'] as String?,
        installmentNumber: m['installmentNumber'] as int?,
        totalInstallments: m['totalInstallments'] as int?,
        installmentGroupId: m['installmentGroupId'] as String?,
        isFixed: (m['isFixed'] as int?) == 1,
        notes: m['notes'] as String?,
        latitude:
            m['latitude'] != null ? (m['latitude'] as num).toDouble() : null,
        longitude:
            m['longitude'] != null ? (m['longitude'] as num).toDouble() : null,
        locationName: m['locationName'] as String?,
      );
}
