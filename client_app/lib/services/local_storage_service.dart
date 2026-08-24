import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/savings_goal_model.dart';
import '../models/reminder_model.dart';

class LocalStorageService {
  static const String transactionsBoxName = 'transactions';
  static const String savingsGoalsBoxName = 'savings_goals';
  static const String remindersBoxName = 'reminders';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(SavingsGoalModelAdapter());
    Hive.registerAdapter(ReminderModelAdapter());
    await Hive.openBox<TransactionModel>(transactionsBoxName);
    await Hive.openBox<SavingsGoalModel>(savingsGoalsBoxName);
    await Hive.openBox<ReminderModel>(remindersBoxName);
  }

  Box<TransactionModel> get _transactionBox => Hive.box<TransactionModel>(transactionsBoxName);
  Box<SavingsGoalModel> get _savingsBox => Hive.box<SavingsGoalModel>(savingsGoalsBoxName);
  Box<ReminderModel> get _remindersBox => Hive.box<ReminderModel>(remindersBoxName);

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

  // ---- Reminders ----
  Future<void> saveReminder(ReminderModel reminder) async {
    await _remindersBox.put(reminder.id, reminder);
  }

  Future<void> deleteReminder(String id) async {
    await _remindersBox.delete(id);
  }

  List<ReminderModel> getAllReminders(String userId) {
    return _remindersBox.values.where((r) => r.userId == userId).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<ReminderModel> getUnsyncedReminders(String userId) {
    return _remindersBox.values
        .where((r) => r.userId == userId && !r.isSynced)
        .toList();
  }
}