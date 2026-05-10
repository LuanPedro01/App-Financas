import 'package:isar/isar.dart';

part 'credit_card_model.g.dart';

enum CardBrand { visa, mastercard, elo, amex, hipercard, other }
enum CardNetwork { credit, debit, both }

@collection
class CreditCardModel {
  CreditCardModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.limit,
    required this.closingDay,
    required this.dueDay,
    required this.color,
    required this.createdAt,
    this.lastFourDigits,
    this.currentInvoiceAmount = 0.0,
    this.availableLimit = 0.0,
    this.cashbackPercent = 0.0,
    this.accountId,
    this.isActive = true,
    this.notes,
    this.updatedAt,
  });

  Id id;
  String name;

  @enumerated
  CardBrand brand;

  double limit;
  double currentInvoiceAmount;
  double availableLimit;
  double cashbackPercent;

  int closingDay;
  int dueDay;
  int color;

  String? lastFourDigits;
  String? accountId;
  bool isActive;
  String? notes;
  DateTime createdAt;
  DateTime? updatedAt;
}
