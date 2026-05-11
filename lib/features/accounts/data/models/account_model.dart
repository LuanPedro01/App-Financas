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

class AccountModel {
  AccountModel({
    this.id = 0,
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

  int id;
  String name;
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

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'type': type.name,
      'balance': balance,
      'initialBalance': initialBalance,
      'color': color,
      'icon': icon,
      'bankName': bankName,
      'bankLogo': bankLogo,
      'isActive': isActive ? 1 : 0,
      'includeInTotal': includeInTotal ? 1 : 0,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
    if (id != 0) map['id'] = id;
    return map;
  }

  factory AccountModel.fromMap(Map<String, dynamic> m) => AccountModel(
        id: m['id'] as int,
        name: m['name'] as String,
        type: AccountType.values.firstWhere(
          (e) => e.name == m['type'],
          orElse: () => AccountType.checking,
        ),
        balance: (m['balance'] as num).toDouble(),
        initialBalance: (m['initialBalance'] as num? ?? 0).toDouble(),
        color: m['color'] as int,
        icon: m['icon'] as String,
        bankName: m['bankName'] as String?,
        bankLogo: m['bankLogo'] as String?,
        isActive: (m['isActive'] as int?) == 1,
        includeInTotal: (m['includeInTotal'] as int? ?? 1) == 1,
        notes: m['notes'] as String?,
        createdAt: DateTime.parse(m['createdAt'] as String),
        updatedAt: m['updatedAt'] != null
            ? DateTime.tryParse(m['updatedAt'] as String)
            : null,
      );
}
