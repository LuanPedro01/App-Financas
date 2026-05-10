import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:financeiro/core/services/database_service.dart';
import 'package:financeiro/features/goals/data/models/goal_model.dart';

class GoalsNotifier
    extends StateNotifier<AsyncValue<List<GoalModel>>> {
  GoalsNotifier() : super(const AsyncValue.loading()) {
    loadAll();
  }

  Isar get _db => DatabaseService.instance;

  Future<void> loadAll() async {
    state = const AsyncValue.loading();
    try {
      final models = await _db.goalModels
          .where()
          .filter()
          .statusEqualTo(GoalStatus.active)
          .or()
          .statusEqualTo(GoalStatus.paused)
          .sortByCreatedAtDesc()
          .findAll();
      state = AsyncValue.data(models);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> add(GoalModel model) async {
    await _db.writeTxn(() => _db.goalModels.put(model));
    await loadAll();
  }

  Future<void> update(GoalModel model) async {
    model.updatedAt = DateTime.now();
    await _db.writeTxn(() => _db.goalModels.put(model));
    await loadAll();
  }

  Future<void> delete(int id) async {
    await _db.writeTxn(() => _db.goalModels.delete(id));
    await loadAll();
  }

  Future<void> contribute(int id, double amount) async {
    final goal = await _db.goalModels.get(id);
    if (goal == null) return;
    goal.currentAmount += amount;
    goal.updatedAt = DateTime.now();
    if (goal.currentAmount >= goal.targetAmount) {
      goal.status = GoalStatus.completed;
    }
    await _db.writeTxn(() => _db.goalModels.put(goal));
    await loadAll();
  }
}

final goalsProvider =
    StateNotifierProvider<GoalsNotifier, AsyncValue<List<GoalModel>>>(
  (ref) => GoalsNotifier(),
);

final activeGoalsProvider = Provider<List<GoalModel>>((ref) {
  final goals = ref.watch(goalsProvider).valueOrNull ?? [];
  return goals.where((g) => g.status == GoalStatus.active).toList();
});
