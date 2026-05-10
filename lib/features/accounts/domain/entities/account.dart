import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:financeiro/features/accounts/data/models/account_model.dart';

part 'account.freezed.dart';
part 'account.g.dart';

@freezed
class Account with _$Account {
  const factory Account({
    required int id,
    required String name,
    required AccountType type,
    required double balance,
    required int color,
    required String icon,
    required DateTime createdAt,
    String? bankName,
    String? bankLogo,
    @Default(0.0) double initialBalance,
    @Default(true) bool isActive,
    @Default(true) bool includeInTotal,
    String? notes,
    DateTime? updatedAt,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

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
}
