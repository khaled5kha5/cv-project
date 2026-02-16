import '../models/project.dart';
import 'base_service.dart';

class ProjectService extends BaseService {
  
  Future<void> createProject(Project project) async {
    await db
    .collection('users')
    .doc(uid)
    .collection('projects')
    .add(project.toMap());
  }

  Stream<List<Project>> getAllProjects() {
    return db
    .collection('users')
    .doc(uid)
    .collection('projects')
    .snapshots()
    .map((snapshot) => snapshot.docs.map((doc) => 
    Project.fromMap(doc.data()..['id'] = doc.id))
    .toList());
  }

  Future<void> updateProject(Project project) async {
    await db
    .collection('users')
    .doc(uid)
    .collection('projects')
    .doc(project.id)
    .set(project.toMap());
  }

  Future<void> deleteProject(String id) async {
    await db
    .collection('users')
    .doc(uid)
    .collection('projects')
    .doc(id)
    .delete();
  }
}
