import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionCloudService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userTransactions(String userId) =>
      _firestore.collection('users').doc(userId).collection('transactions');

  Future<void> pushTransaction(TransactionModel transaction) async {
    await _userTransactions(transaction.userId)
        .doc(transaction.id)
        .set(transaction.toMap());
  }

  Future<void> deleteTransaction(String userId, String transactionId) async {
    await _userTransactions(userId).doc(transactionId).delete();
  }

  Future<List<TransactionModel>> fetchAllTransactions(String userId) async {
    final snapshot = await _userTransactions(userId).get();
    return snapshot.docs.map((doc) => TransactionModel.fromMap(doc.data())).toList();
  }
}