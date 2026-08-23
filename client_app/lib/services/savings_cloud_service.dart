import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/savings_goal_model.dart';

class SavingsCloudService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userGoals(String userId) =>
      _firestore.collection('users').doc(userId).collection('savings_goals');

  Future<void> pushGoal(SavingsGoalModel goal) async {
    await _userGoals(goal.userId).doc(goal.id).set(goal.toMap());
  }

  Future<void> deleteGoal(String userId, String goalId) async {
    await _userGoals(userId).doc(goalId).delete();
  }

  Future<List<SavingsGoalModel>> fetchAllGoals(String userId) async {
    final snapshot = await _userGoals(userId).get();
    return snapshot.docs.map((doc) => SavingsGoalModel.fromMap(doc.data())).toList();
  }
}