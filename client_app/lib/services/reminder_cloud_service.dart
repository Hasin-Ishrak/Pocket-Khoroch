import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reminder_model.dart';

class ReminderCloudService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userReminders(String userId) =>
      _firestore.collection('users').doc(userId).collection('reminders');

  Future<void> pushReminder(ReminderModel reminder) async {
    await _userReminders(reminder.userId).doc(reminder.id).set(reminder.toMap());
  }

  Future<void> deleteReminder(String userId, String reminderId) async {
    await _userReminders(userId).doc(reminderId).delete();
  }

  Future<List<ReminderModel>> fetchAllReminders(String userId) async {
    final snapshot = await _userReminders(userId).get();
    return snapshot.docs.map((doc) => ReminderModel.fromMap(doc.data())).toList();
  }
}