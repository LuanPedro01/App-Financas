import 'package:isar/isar.dart';

part 'investment_asset_model.g.dart';

@collection
class InvestmentAssetModel {
  InvestmentAssetModel({
    required this.id,
    required this.investmentId,
    required this.date,
    required this.quantity,
    required this.price,
    required this.type,
    this.fees = 0.0,
    this.notes,
  });

  Id id;
  int investmentId;
  DateTime date;
  double quantity;
  double price;
  String type; // 'buy' | 'sell' | 'dividend'
  double fees;
  String? notes;
}
