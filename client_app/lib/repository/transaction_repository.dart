import '../models/transaction_model.dart';
import '../services/local_storage_service.dart';
import '../services/transaction_cloud_service.dart';

class TransactionRepository {
  final LocalStorageService _localService;
  final TransactionCloudService _cloudService;

  TransactionRepository({
    required LocalStorageService localService,
    required TransactionCloudService cloudService,
  })  : _localService = localService,
        _cloudService = cloudService;

  /// Saves locally first (instant), then tries syncing to cloud in background.
  Future<void> addTransaction(TransactionModel transaction) async {
    await _localService.saveTransaction(transaction);
    _syncInBackground(transaction);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final updated = transaction.copyWith(isSynced: false);
    await _localService.saveTransaction(updated);
    _syncInBackground(updated);
  }

  Future<void> deleteTransaction(String userId, String transactionId) async {
    await _localService.deleteTransaction(transactionId);
    try {
      await _cloudService.deleteTransaction(userId, transactionId);
    } catch (_) {
      // Silently fail — will still be gone locally. Could add a "pending deletes" queue later.
    }
  }

  List<TransactionModel> getLocalTransactions(String userId) {
    return _localService.getAllTransactions(userId);
  }

  Future<void> _syncInBackground(TransactionModel transaction) async {
    try {
      await _cloudService.pushTransaction(transaction);
      final synced = transaction.copyWith(isSynced: true);
      await _localService.saveTransaction(synced);
    } catch (_) {
      // No internet or error — stays isSynced = false, will retry later via syncPendingTransactions()
    }
  }

  /// Call this on app start or when connectivity returns, to push any offline-created transactions.
  Future<void> syncPendingTransactions(String userId) async {
    final pending = _localService.getUnsyncedTransactions(userId);
    for (final t in pending) {
      await _syncInBackground(t);
    }
  }

  /// Pulls latest from cloud and merges into local (used on fresh login / new device).
  Future<void> pullAndMergeFromCloud(String userId) async {
    try {
      final cloudTransactions = await _cloudService.fetchAllTransactions(userId);
      for (final t in cloudTransactions) {
        await _localService.saveTransaction(t);
      }
    } catch (_) {
      // Offline — skip, local data still usable
    }
  }
}