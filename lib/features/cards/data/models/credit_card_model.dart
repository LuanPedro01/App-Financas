enum CardBrand { visa, mastercard, elo, amex, hipercard, other }

enum CardNetwork { credit, debit, both }

class CreditCardModel {
  CreditCardModel({
    this.id = 0,
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

  int id;
  String name;
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

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'brand': brand.name,
      'limit': limit,
      'currentInvoiceAmount': currentInvoiceAmount,
      'availableLimit': availableLimit,
      'cashbackPercent': cashbackPercent,
      'closingDay': closingDay,
      'dueDay': dueDay,
      'color': color,
      'lastFourDigits': lastFourDigits,
      'accountId': accountId,
      'isActive': isActive ? 1 : 0,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
    if (id != 0) map['id'] = id;
    return map;
  }

  factory CreditCardModel.fromMap(Map<String, dynamic> m) => CreditCardModel(
        id: m['id'] as int,
        name: m['name'] as String,
        brand: CardBrand.values.firstWhere(
          (e) => e.name == m['brand'],
          orElse: () => CardBrand.other,
        ),
        limit: (m['limit'] as num).toDouble(),
        currentInvoiceAmount:
            (m['currentInvoiceAmount'] as num? ?? 0).toDouble(),
        availableLimit: (m['availableLimit'] as num? ?? 0).toDouble(),
        cashbackPercent: (m['cashbackPercent'] as num? ?? 0).toDouble(),
        closingDay: m['closingDay'] as int,
        dueDay: m['dueDay'] as int,
        color: m['color'] as int,
        lastFourDigits: m['lastFourDigits'] as String?,
        accountId: m['accountId'] as String?,
        isActive: (m['isActive'] as int? ?? 1) == 1,
        notes: m['notes'] as String?,
        createdAt: DateTime.parse(m['createdAt'] as String),
        updatedAt: m['updatedAt'] != null
            ? DateTime.tryParse(m['updatedAt'] as String)
            : null,
      );
}
