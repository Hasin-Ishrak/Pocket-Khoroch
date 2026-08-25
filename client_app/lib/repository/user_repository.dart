import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  Future<void> createUserProfile(AppUser user) async {
    final doc = await _usersCollection.doc(user.uid).get();
    if (!doc.exists) {
      await _usersCollection.doc(user.uid).set(user.toMap());
    }
  }

  Future<AppUser?> getUserProfile(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!);
  }

  Future<void> updateUserProfile(AppUser user) async {
    await _usersCollection.doc(user.uid).update(user.toMap());
  }

  Stream<AppUser?> watchUserProfile(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromMap(doc.data()!);
    });
  }
}
