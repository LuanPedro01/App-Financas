import 'package:financeiro/features/transactions/domain/enums/transaction_enums.dart';
import 'package:financeiro/features/transactions/data/models/transaction_model.dart';

class Transaction {
  const Transaction({
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

  final int id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? description;
  final String? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final int? categoryColor;
  final String? accountId;
  final String? accountName;
  final String? toAccountId;
  final String? toAccountName;
  final String? cardId;
  final String? cardName;
  final List<String> tags;
  final List<String> attachments;
  final TransactionStatus status;
  final PaymentMethod paymentMethod;
  final RecurrenceType recurrenceType;
  final String? recurrenceGroupId;
  final int? installmentNumber;
  final int? totalInstallments;
  final String? installmentGroupId;
  final bool isFixed;
  final String? notes;
  final double? latitude;
  final double? longitude;
  final String? locationName;

  factory Transaction.fromModel(TransactionModel m) => Transaction(
        id: m.id,
        title: m.title,
        amount: m.amount,
        type: m.type,
        date: m.date,
        createdAt: m.createdAt,
        description: m.description,
        categoryId: m.categoryId,
        categoryName: m.categoryName,
        categoryIcon: m.categoryIcon,
        categoryColor: m.categoryColor,
        accountId: m.accountId,
        accountName: m.accountName,
        toAccountId: m.toAccountId,
        toAccountName: m.toAccountName,
        cardId: m.cardId,
        cardName: m.cardName,
        tags: List.unmodifiable(m.tags),
        attachments: List.unmodifiable(m.attachments),
        status: m.status,
        paymentMethod: m.paymentMethod,
        recurrenceType: m.recurrenceType,
        recurrenceGroupId: m.recurrenceGroupId,
        installmentNumber: m.installmentNumber,
        totalInstallments: m.totalInstallments,
        installmentGroupId: m.installmentGroupId,
        isFixed: m.isFixed,
        notes: m.notes,
        latitude: m.latitude,
        longitude: m.longitude,
        locationName: m.locationName,
        updatedAt: m.updatedAt,
      );

  Transaction copyWith({
    int? id,
    String? title,
    double? amount,
    TransactionType? type,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? description,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    int? categoryColor,
    String? accountId,
    String? accountName,
    String? toAccountId,
    String? toAccountName,
    String? cardId,
    String? cardName,
    List<String>? tags,
    List<String>? attachments,
    TransactionStatus? status,
    PaymentMethod? paymentMethod,
    RecurrenceType? recurrenceType,
    String? recurrenceGroupId,
    int? installmentNumber,
    int? totalInstallments,
    String? installmentGroupId,
    bool? isFixed,
    String? notes,
    double? latitude,
    double? longitude,
    String? locationName,
  }) =>
      Transaction(
        id: id ?? this.id,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        date: date ?? this.date,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        description: description ?? this.description,
        categoryId: categoryId ?? this.categoryId,
        categoryName: categoryName ?? this.categoryName,
        categoryIcon: categoryIcon ?? this.categoryIcon,
        categoryColor: categoryColor ?? this.categoryColor,
        accountId: accountId ?? this.accountId,
        accountName: accountName ?? this.accountName,
        toAccountId: toAccountId ?? this.toAccountId,
        toAccountName: toAccountName ?? this.toAccountName,
        cardId: cardId ?? this.cardId,
        cardName: cardName ?? this.cardName,
        tags: tags ?? this.tags,
        attachments: attachments ?? this.attachments,
        status: status ?? this.status,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        recurrenceType: recurrenceType ?? this.recurrenceType,
        recurrenceGroupId: recurrenceGroupId ?? this.recurrenceGroupId,
        installmentNumber: installmentNumber ?? this.installmentNumber,
        totalInstallments: totalInstallments ?? this.totalInstallments,
        installmentGroupId: installmentGroupId ?? this.installmentGroupId,
        isFixed: isFixed ?? this.isFixed,
        notes: notes ?? this.notes,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        locationName: locationName ?? this.locationName,
      );
}

extension TransactionExtensions on Transaction {
  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
  bool get isTransfer => type == TransactionType.transfer;
  bool get isInstallment =>
      installmentNumber != null && totalInstallments != null;
  bool get isRecurring => recurrenceType != RecurrenceType.none;
  bool get isPending => status == TransactionStatus.pending;
  bool get isCompleted => status == TransactionStatus.completed;

  double get signedAmount => isExpense ? -amount.abs() : amount.abs();

  String get installmentLabel =>
      isInstallment ? '$installmentNumber/$totalInstallments' : '';
}
