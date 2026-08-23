import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/savings_goal_model.dart';

class LocalStorageService {
  static const String transactionsBoxName = 'transactions';
  static const String savingsGoalsBoxName = 'savings_goals';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(SavingsGoalModelAdapter());
    await Hive.openBox<TransactionModel>(transactionsBoxName);
    await Hive.openBox<SavingsGoalModel>(savingsGoalsBoxName);
  }

  Box<TransactionModel> get _transactionBox => Hive.box<TransactionModel>(transactionsBoxName);
  Box<SavingsGoalModel> get _savingsBox => Hive.box<SavingsGoalModel>(savingsGoalsBoxName);

  // ---- Transactions ----
  Future<void> saveTransaction(TransactionModel transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionBox.delete(id);
  }

  List<TransactionModel> getAllTransactions(String userId) {
    return _transactionBox.values.where((t) => t.userId == userId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<TransactionModel> getUnsyncedTransactions(String userId) {
    return _transactionBox.values
        .where((t) => t.userId == userId && !t.isSynced)
        .toList();
  }

  TransactionModel? getTransaction(String id) {
    return _transactionBox.get(id);
  }

  // ---- Savings Goals ----
  Future<void> saveSavingsGoal(SavingsGoalModel goal) async {
    await _savingsBox.put(goal.id, goal);
  }

  Future<void> deleteSavingsGoal(String id) async {
    await _savingsBox.delete(id);
  }

  List<SavingsGoalModel> getAllSavingsGoals(String userId) {
    return _savingsBox.values.where((g) => g.userId == userId).toList()
      ..sort((a, b) => a.targetDate.compareTo(b.targetDate));
  }

  List<SavingsGoalModel> getUnsyncedSavingsGoals(String userId) {
    return _savingsBox.values
        .where((g) => g.userId == userId && !g.isSynced)
        .toList();
  }
}