import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:financeiro/features/transactions/domain/enums/transaction_enums.dart';
import 'package:financeiro/features/transactions/data/models/transaction_model.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required int id,
    required String title,
    required double amount,
    required TransactionType type,
    required DateTime date,
    required DateTime createdAt,
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
    @Default([]) List<String> tags,
    @Default([]) List<String> attachments,
    @Default(TransactionStatus.completed) TransactionStatus status,
    @Default(PaymentMethod.pix) PaymentMethod paymentMethod,
    @Default(RecurrenceType.none) RecurrenceType recurrenceType,
    String? recurrenceGroupId,
    int? installmentNumber,
    int? totalInstallments,
    String? installmentGroupId,
    @Default(false) bool isFixed,
    String? notes,
    double? latitude,
    double? longitude,
    String? locationName,
    DateTime? updatedAt,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

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
        tags: m.tags,
        attachments: m.attachments,
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

  double get signedAmount =>
      isExpense ? -amount.abs() : amount.abs();

  String get installmentLabel =>
      isInstallment ? '$installmentNumber/$totalInstallments' : '';
}
