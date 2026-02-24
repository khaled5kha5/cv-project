import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cv_project1/services/auth_service.dart';


class FirestoreService {
  final db = FirebaseFirestore.instance;
  final auth = AuthService();
  final collectionName = "users";

  String? get currentUserId => auth.uid;

  Future<String?> getUserName(String uid) async {
    try {
      final doc = await db.collection(collectionName).doc(uid).get();
      if (doc.exists) {
        String name = doc.data()?['username'] ?? 'No name';
        return name;
      }
      return 'No name';
    } catch (e) {
      throw Exception('Error fetching user name: $e');
    }
  }
  
  Future<void> addUser({
    required String uid,
    required String email,
    required String username,
  }) async {
    try {
      await db.collection(collectionName).doc(uid).set({
        'uid': uid,
        'email': email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error adding user: $e');
    }
  }

  Future<Map<String,dynamic>> getUser(String uid) async {
    try {
      final doc = await db.collection(collectionName).doc(uid).get();
      if (doc.exists) {
        return doc.data()!;
      }
      throw Exception('User not found');
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }


  
}