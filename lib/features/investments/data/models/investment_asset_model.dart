class InvestmentAssetModel {
  InvestmentAssetModel({
    this.id = 0,
    required this.investmentId,
    required this.date,
    required this.quantity,
    required this.price,
    required this.type,
    this.fees = 0.0,
    this.notes,
  });

  int id;
  int investmentId;
  DateTime date;
  double quantity;
  double price;
  String type; // 'buy' | 'sell' | 'dividend'
  double fees;
  String? notes;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'investmentId': investmentId,
      'date': date.toIso8601String(),
      'quantity': quantity,
      'price': price,
      'type': type,
      'fees': fees,
      'notes': notes,
    };
    if (id != 0) map['id'] = id;
    return map;
  }

  factory InvestmentAssetModel.fromMap(Map<String, dynamic> m) =>
      InvestmentAssetModel(
        id: m['id'] as int,
        investmentId: m['investmentId'] as int,
        date: DateTime.parse(m['date'] as String),
        quantity: (m['quantity'] as num).toDouble(),
        price: (m['price'] as num).toDouble(),
        type: m['type'] as String,
        fees: (m['fees'] as num? ?? 0).toDouble(),
        notes: m['notes'] as String?,
      );
}
