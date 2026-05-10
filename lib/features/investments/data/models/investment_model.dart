import 'package:isar/isar.dart';

part 'investment_model.g.dart';

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

@collection
class InvestmentModel {
  InvestmentModel({
    required this.id,
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

  Id id;
  String name;
  String ticker;

  @enumerated
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
}
