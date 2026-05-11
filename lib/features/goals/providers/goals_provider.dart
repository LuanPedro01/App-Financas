import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financeiro/core/services/database_service.dart';
import 'package:financeiro/features/goals/data/models/goal_model.dart';

class GoalsNotifier extends StateNotifier<AsyncValue<List<GoalModel>>> {
  GoalsNotifier() : super(const AsyncValue.loading()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = const AsyncValue.loading();
    try {
      final models = await DatabaseService.getActiveGoals();
      state = AsyncValue.data(models);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> add(GoalModel model) async {
    await DatabaseService.insertGoal(model);
    await loadAll();
  }

  Future<void> update(GoalModel model) async {
    model.updatedAt = DateTime.now();
    await DatabaseService.updateGoal(model);
    await loadAll();
  }

  Future<void> delete(int id) async {
    await DatabaseService.deleteGoal(id);
    await loadAll();
  }

  Future<void> contribute(int id, double amount) async {
    await DatabaseService.contributeToGoal(id, amount);
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
