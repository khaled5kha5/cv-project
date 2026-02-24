import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cv_project1/models/cv_model.dart';

import 'package:cv_project1/services/firestore_service.dart';


class CvService extends FirestoreService{
  
  final _db = FirebaseFirestore.instance;
  final _collectionName = "cvs";
  
  Future<void> addCv(CvModel cv) async {
    try {
      await _db.collection('users').doc(currentUserId).collection(_collectionName).add(cv.toFirestore());
    } catch (e) {
      throw Exception('Error adding CV: $e');
    }
  }

  Stream<List<CvModel>> getCvsStream() {
    try {
      return _db.collection('users').doc(currentUserId).collection(_collectionName).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => CvModel.fromFirestore(doc.data(), doc.id)).toList()
      );
    } catch (e) {
      throw Exception('Error fetching CVs stream: $e');
    }
  }

  Future<void> updateCv(CvModel cv) async {
    try {
      await _db.collection('users').doc(currentUserId).collection(_collectionName).doc(cv.id).update(cv.toFirestore());
    } catch (e) {
      throw Exception('Error updating CV: $e');
    }
  }

  Future<void> deleteCv(String cvId) async {
    try {
      await _db.collection('users').doc(currentUserId).collection(_collectionName).doc(cvId).delete();
    } catch (e) {
      throw Exception('Error deleting CV: $e');
    }
  }

  Stream<CvModel> getCvById(String cvId) {
    try {
      final doc = _db.collection('users').doc(currentUserId).collection(_collectionName).doc(cvId).snapshots();
      return doc.map((snapshot) {
        if (snapshot.exists) {
          return CvModel.fromFirestore(snapshot.data()!, snapshot.id);
        }
        throw Exception('CV not found');
      });
    } catch (e) {
      throw Exception('Error fetching CV: $e');
    }
  }

  Future<CvModel?> getCvByIdOnce(String cvId) async {
    try {
      final doc = await _db.collection('users').doc(currentUserId).collection(_collectionName).doc(cvId).get();
      if (doc.exists) {
        return CvModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching CV: $e');
    }
  }

}