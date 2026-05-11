enum InvestmentType {
  stock,
  fii,
  etf,
  crypto,
  fixedIncome,
  treasuryDirect,
  mutualFund,
  other;

  String get label => switch (this) {
        stock => 'Ações',
        fii => 'FII',
        etf => 'ETF',
        crypto => 'Cripto',
        fixedIncome => 'Renda Fixa',
        treasuryDirect => 'Tesouro Direto',
        mutualFund => 'Fundo de Investimento',
        other => 'Outro',
      };
}

class InvestmentModel {
  InvestmentModel({
    this.id = 0,
    required this.name,
    required this.ticker,
    required this.type,
    required this.quantity,
    required this.avgPrice,
    required this.currentPrice,
    required this.createdAt,
    this.dividendsReceived = 0.0,
    this.notes,
    this.updatedAt,
  });

  int id;
  String name;
  String ticker;
  InvestmentType type;
  double quantity;
  double avgPrice;
  double currentPrice;
  double dividendsReceived;
  String? notes;
  DateTime createdAt;
  DateTime? updatedAt;

  double get totalInvested => quantity * avgPrice;
  double get currentValue => quantity * currentPrice;
  double get profitLoss => currentValue - totalInvested;
  double get profitLossPercent =>
      totalInvested > 0 ? profitLoss / totalInvested : 0.0;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'ticker': ticker,
      'type': type.name,
      'quantity': quantity,
      'avgPrice': avgPrice,
      'currentPrice': currentPrice,
      'dividendsReceived': dividendsReceived,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
    if (id != 0) map['id'] = id;
    return map;
  }

  factory InvestmentModel.fromMap(Map<String, dynamic> m) => InvestmentModel(
        id: m['id'] as int,
        name: m['name'] as String,
        ticker: m['ticker'] as String,
        type: InvestmentType.values.firstWhere(
          (e) => e.name == m['type'],
          orElse: () => InvestmentType.other,
        ),
        quantity: (m['quantity'] as num).toDouble(),
        avgPrice: (m['avgPrice'] as num).toDouble(),
        currentPrice: (m['currentPrice'] as num).toDouble(),
        dividendsReceived:
            (m['dividendsReceived'] as num? ?? 0).toDouble(),
        notes: m['notes'] as String?,
        createdAt: DateTime.parse(m['createdAt'] as String),
        updatedAt: m['updatedAt'] != null
            ? DateTime.tryParse(m['updatedAt'] as String)
            : null,
      );
}
