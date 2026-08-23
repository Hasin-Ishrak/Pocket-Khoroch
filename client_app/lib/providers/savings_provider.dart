import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/savings_goal_model.dart';
import '../repository/savings_repository.dart';

class SavingsProvider extends ChangeNotifier {
  final SavingsRepository _repository;
  final _uuid = const Uuid();

  SavingsProvider({required SavingsRepository repository}) : _repository = repository;

  List<SavingsGoalModel> _goals = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SavingsGoalModel> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadGoals(String userId, {bool syncFirst = false}) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (syncFirst) {
        await _repository.pullAndMergeFromCloud(userId);
      }
      _goals = _repository.getLocalGoals(userId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load savings goals';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addGoal({
    required String userId,
    required String title,
    required double targetAmount,
    required DateTime targetDate,
  }) async {
    try {
      final goal = SavingsGoalModel(
        id: _uuid.v4(),
        userId: userId,
        title: title,
        targetAmount: targetAmount,
        targetDate: targetDate,
        createdAt: DateTime.now(),
      );
      await _repository.addGoal(goal);
      _goals.add(goal);
      _goals.sort((a, b) => a.targetDate.compareTo(b.targetDate));
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add goal';
      notifyListeners();
      return false;
    }
  }

  Future<bool> addToSavings(String goalId, double amount) async {
    try {
      final index = _goals.indexWhere((g) => g.id == goalId);
      if (index == -1) return false;
      final updated = _goals[index].copyWith(
        savedAmount: _goals[index].savedAmount + amount,
      );
      await _repository.updateGoal(updated);
      _goals[index] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update goal';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteGoal(String userId, String goalId) async {
    try {
      await _repository.deleteGoal(userId, goalId);
      _goals.removeWhere((g) => g.id == goalId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete goal';
      notifyListeners();
      return false;
    }
  }
}