import 'package:financeiro/features/accounts/data/models/account_model.dart';

class Account {
  const Account({
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

  final int id;
  final String name;
  final AccountType type;
  final double balance;
  final double initialBalance;
  final int color;
  final String icon;
  final String? bankName;
  final String? bankLogo;
  final bool isActive;
  final bool includeInTotal;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory Account.fromModel(AccountModel m) => Account(
        id: m.id,
        name: m.name,
        type: m.type,
        balance: m.balance,
        color: m.color,
        icon: m.icon,
        createdAt: m.createdAt,
        bankName: m.bankName,
        bankLogo: m.bankLogo,
        initialBalance: m.initialBalance,
        isActive: m.isActive,
        includeInTotal: m.includeInTotal,
        notes: m.notes,
        updatedAt: m.updatedAt,
      );

  Account copyWith({
    int? id,
    String? name,
    AccountType? type,
    double? balance,
    double? initialBalance,
    int? color,
    String? icon,
    String? bankName,
    String? bankLogo,
    bool? isActive,
    bool? includeInTotal,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Account(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        balance: balance ?? this.balance,
        initialBalance: initialBalance ?? this.initialBalance,
        color: color ?? this.color,
        icon: icon ?? this.icon,
        bankName: bankName ?? this.bankName,
        bankLogo: bankLogo ?? this.bankLogo,
        isActive: isActive ?? this.isActive,
        includeInTotal: includeInTotal ?? this.includeInTotal,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
