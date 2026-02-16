import '../models/education.dart';
import 'base_service.dart';

class EducationService extends BaseService {
  EducationService._privateConstructor();
  static final EducationService instance = EducationService._privateConstructor();

  Future<void> createEducation(Education education) async {
    await db
    .collection('users')
    .doc(uid)
    .collection('education')
    .add(education.toMap());
  }

  Stream<List<Education>> getAllEducations() {
     return db
    .collection('users')
    .doc(uid)
    .collection('education')
    .snapshots()
    .map((snapshot) => snapshot.docs.map((doc) => 
    Education.fromMap(doc.data()..['id'] = doc.id))
    .toList());

  }

  Future<void> updateEducation(Education education) async {
    await db
    .collection('users')
    .doc(uid)
    .collection('education')
    .doc(education.id)
    .set(education.toMap());
  }

  Future<void> deleteEducation(String id) async {
    await db
    .collection('users')
    .doc(uid)
    .collection('education')
    .doc(id)
    .delete();
  }
}
