import 'package:isar/isar.dart';

part 'goal_model.g.dart';

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

@collection
class GoalModel {
  GoalModel({
    required this.id,
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

  Id id;
  String name;
  double targetAmount;
  double currentAmount;
  double monthlyContribution;

  @enumerated
  GoalType type;

  @enumerated
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
  double get remaining => (targetAmount - currentAmount).clamp(0.0, double.infinity);
  bool get isCompleted => currentAmount >= targetAmount;
}
