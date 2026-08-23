import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../repository/transaction_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repository;
  final _uuid = const Uuid();

  TransactionProvider({required TransactionRepository repository})
      : _repository = repository;

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<TransactionModel> get incomeTransactions =>
      _transactions.where((t) => t.isIncome).toList();

  List<TransactionModel> get expenseTransactions =>
      _transactions.where((t) => t.isExpense).toList();

  double get totalIncome =>
      incomeTransactions.fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense =>
      expenseTransactions.fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  Future<void> loadTransactions(String userId, {bool syncFirst = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (syncFirst) {
        await _repository.pullAndMergeFromCloud(userId);
      }
      _transactions = _repository.getLocalTransactions(userId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load transactions';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTransaction({
    required String userId,
    required double amount,
    required String type,
    required String categoryId,
    required DateTime date,
    String? note,
  }) async {
    try {
      final transaction = TransactionModel(
        id: _uuid.v4(),
        userId: userId,
        amount: amount,
        type: type,
        categoryId: categoryId,
        date: date,
        note: note,
        createdAt: DateTime.now(),
      );
      await _repository.addTransaction(transaction);
      _transactions.insert(0, transaction);
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add transaction';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(String userId, String transactionId) async {
    try {
      await _repository.deleteTransaction(userId, transactionId);
      _transactions.removeWhere((t) => t.id == transactionId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete transaction';
      notifyListeners();
      return false;
    }
  }

  Future<void> syncPending(String userId) async {
    await _repository.syncPendingTransactions(userId);
  }
}