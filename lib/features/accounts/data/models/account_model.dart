import 'package:isar/isar.dart';

part 'account_model.g.dart';

enum AccountType {
  checking,
  savings,
  wallet,
  investment,
  other;

  String get label => switch (this) {
        checking => 'Conta Corrente',
        savings => 'Poupança',
        wallet => 'Carteira',
        investment => 'Investimentos',
        other => 'Outro',
      };
}

@collection
class AccountModel {
  AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.color,
    required this.icon,
    required this.createdAt,
    this.bankName,
    this.bankLogo,
    this.initialBalance = 0.0,
    this.isActive = true,
    this.includeInTotal = true,
    this.notes,
    this.updatedAt,
  });

  Id id;
  String name;

  @enumerated
  AccountType type;

  double balance;
  double initialBalance;
  int color;
  String icon;
  String? bankName;
  String? bankLogo;
  bool isActive;
  bool includeInTotal;
  String? notes;
  DateTime createdAt;
  DateTime? updatedAt;
}
