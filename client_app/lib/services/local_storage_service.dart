import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';

class LocalStorageService {
  static const String transactionsBoxName = 'transactions';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionModelAdapter());
    await Hive.openBox<TransactionModel>(transactionsBoxName);
  }

  Box<TransactionModel> get _box => Hive.box<TransactionModel>(transactionsBoxName);

  Future<void> saveTransaction(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
  }

  List<TransactionModel> getAllTransactions(String userId) {
    return _box.values.where((t) => t.userId == userId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<TransactionModel> getUnsyncedTransactions(String userId) {
    return _box.values
        .where((t) => t.userId == userId && !t.isSynced)
        .toList();
  }

  TransactionModel? getTransaction(String id) {
    return _box.get(id);
  }
}