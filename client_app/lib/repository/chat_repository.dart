import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userChat(String userId) =>
      _firestore.collection('users').doc(userId).collection('chat_messages');

  Future<void> saveMessage(ChatMessageModel message) async {
    await _userChat(message.userId).doc(message.id).set(message.toMap());
  }

  Future<List<ChatMessageModel>> fetchHistory(String userId, {int limit = 50}) async {
    final snapshot = await _userChat(userId)
        .orderBy('timestamp', descending: false)
        .limitToLast(limit)
        .get();
    return snapshot.docs.map((doc) => ChatMessageModel.fromMap(doc.data())).toList();
  }

  Future<void> clearHistory(String userId) async {
    final snapshot = await _userChat(userId).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}