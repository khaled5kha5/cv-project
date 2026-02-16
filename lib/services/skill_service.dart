import '../models/skill.dart';
import 'base_service.dart';

class SkillService extends BaseService {
  
  Future<void> createSkill(Skill skill) async {
    await db
    .collection('users')
    .doc(uid)
    .collection('skills')
    .add(skill.toMap());
  }

  Stream<List<Skill>> getAllSkills()  {
    return db
    .collection('users')
    .doc(uid)
    .collection('skills')
    .snapshots()
    .map((snapshot) => snapshot.docs.map((doc) => 
    Skill.fromMap(doc.data()..['id'] = doc.id))
    .toList());
  }

    
  

  Future<void> updateSkill(Skill skill) async {
    await db
    .collection('users')
    .doc(uid)
    .collection('skills')
    .doc(skill.id)
    .set(skill.toMap());
  }

  Future<void> deleteSkill(String id) async {
    await db
    .collection('users')
    .doc(uid)
    .collection('skills')
    .doc(id)
    .delete();
  }
}
