import '../models/savings_goal_model.dart';
import '../services/local_storage_service.dart';
import '../services/savings_cloud_service.dart';

class SavingsRepository {
  final LocalStorageService _localService;
  final SavingsCloudService _cloudService;

  SavingsRepository({
    required LocalStorageService localService,
    required SavingsCloudService cloudService,
  })  : _localService = localService,
        _cloudService = cloudService;

  Future<void> addGoal(SavingsGoalModel goal) async {
    await _localService.saveSavingsGoal(goal);
    _syncInBackground(goal);
  }

  Future<void> updateGoal(SavingsGoalModel goal) async {
    final updated = goal.copyWith(isSynced: false);
    await _localService.saveSavingsGoal(updated);
    _syncInBackground(updated);
  }

  Future<void> deleteGoal(String userId, String goalId) async {
    await _localService.deleteSavingsGoal(goalId);
    try {
      await _cloudService.deleteGoal(userId, goalId);
    } catch (_) {}
  }

  List<SavingsGoalModel> getLocalGoals(String userId) {
    return _localService.getAllSavingsGoals(userId);
  }

  Future<void> _syncInBackground(SavingsGoalModel goal) async {
    try {
      await _cloudService.pushGoal(goal);
      final synced = goal.copyWith(isSynced: true);
      await _localService.saveSavingsGoal(synced);
    } catch (_) {}
  }

  Future<void> syncPendingGoals(String userId) async {
    final pending = _localService.getUnsyncedSavingsGoals(userId);
    for (final g in pending) {
      await _syncInBackground(g);
    }
  }

  Future<void> pullAndMergeFromCloud(String userId) async {
    try {
      final cloudGoals = await _cloudService.fetchAllGoals(userId);
      for (final g in cloudGoals) {
        await _localService.saveSavingsGoal(g);
      }
    } catch (_) {}
  }
}