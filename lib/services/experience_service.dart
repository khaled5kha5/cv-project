import '../models/experience.dart';
import 'base_service.dart';

class ExperienceService extends BaseService {
  

  Future<void> createExperience(Experience experience) async {
    await db
    .collection('users')
    .doc(uid)
    .collection('experience')
    .add(experience.toMap());
  }

  Stream<List<Experience>> getAllExperiences()  {
    return db
    .collection('users')
    .doc(uid)
    .collection('experience')
    .snapshots()
    .map((snapshot) => snapshot.docs.map((doc) => 
    Experience.fromMap(doc.data()..['id'] = doc.id))
    .toList());

  }

  Future<void> updateExperience(Experience experience) async {
    await db
    .collection('users')
    .doc(uid)
    .collection('experience')
    .doc(experience.id)
    .set(experience.toMap());
  }

  Future<void> deleteExperience(String id) async {
    await db
    .collection('users')
    .doc(uid)
    .collection('experience')
    .doc(id)
    .delete();
  }
}
