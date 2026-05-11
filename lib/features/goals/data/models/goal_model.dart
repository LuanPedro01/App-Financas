enum GoalType {
  emergency,
  travel,
  purchase,
  retirement,
  education,
  health,
  custom;

  String get label => switch (this) {
        emergency => 'Reserva de Emergência',
        travel => 'Viagem',
        purchase => 'Compra',
        retirement => 'Aposentadoria',
        education => 'Educação',
        health => 'Saúde',
        custom => 'Personalizado',
      };
}

enum GoalStatus { active, completed, paused, cancelled }

class GoalModel {
  GoalModel({
    this.id = 0,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.type,
    required this.color,
    required this.icon,
    required this.createdAt,
    this.targetDate,
    this.monthlyContribution = 0.0,
    this.status = GoalStatus.active,
    this.accountId,
    this.notes,
    this.updatedAt,
  });

  int id;
  String name;
  double targetAmount;
  double currentAmount;
  double monthlyContribution;
  GoalType type;
  GoalStatus status;
  int color;
  String icon;
  DateTime? targetDate;
  String? accountId;
  String? notes;
  DateTime createdAt;
  DateTime? updatedAt;

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  double get remaining =>
      (targetAmount - currentAmount).clamp(0.0, double.infinity);
  bool get isCompleted => currentAmount >= targetAmount;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'monthlyContribution': monthlyContribution,
      'type': type.name,
      'status': status.name,
      'color': color,
      'icon': icon,
      'targetDate': targetDate?.toIso8601String(),
      'accountId': accountId,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
    if (id != 0) map['id'] = id;
    return map;
  }

  factory GoalModel.fromMap(Map<String, dynamic> m) => GoalModel(
        id: m['id'] as int,
        name: m['name'] as String,
        targetAmount: (m['targetAmount'] as num).toDouble(),
        currentAmount: (m['currentAmount'] as num? ?? 0).toDouble(),
        monthlyContribution:
            (m['monthlyContribution'] as num? ?? 0).toDouble(),
        type: GoalType.values.firstWhere(
          (e) => e.name == m['type'],
          orElse: () => GoalType.custom,
        ),
        status: GoalStatus.values.firstWhere(
          (e) => e.name == m['status'],
          orElse: () => GoalStatus.active,
        ),
        color: m['color'] as int,
        icon: m['icon'] as String,
        targetDate: m['targetDate'] != null
            ? DateTime.tryParse(m['targetDate'] as String)
            : null,
        accountId: m['accountId'] as String?,
        notes: m['notes'] as String?,
        createdAt: DateTime.parse(m['createdAt'] as String),
        updatedAt: m['updatedAt'] != null
            ? DateTime.tryParse(m['updatedAt'] as String)
            : null,
      );
}
