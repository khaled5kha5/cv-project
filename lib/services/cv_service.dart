import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cv_project1/models/cv.dart';
import 'package:cv_project1/models/experience.dart';
import 'package:cv_project1/models/education.dart';
import 'package:cv_project1/models/skill.dart';
import 'package:cv_project1/models/project.dart';
import 'firestore_service.dart';

class CVService extends FirestoreService<CV> {
  CVService._privateConstructor();
  static final CVService instance = CVService._privateConstructor();

  @override
  CollectionReference<Map<String, dynamic>> get collectionRef {
    final userId = uid;
    final path = 'users/$userId/cvs';
    print('CVService: Collection path = $path');
    return db.collection('users').doc(userId).collection('cvs');
  }

  @override
  CV fromJson(Map<String, dynamic> json, {String? docId}) {
    return CV.fromMap(json, docId: docId);
  }

  @override
  Map<String, dynamic> toJson(CV model) {
    // Use toMap() which handles server timestamps and excludes nested lists
    return model.toMap();
  }

  /// Create a new CV
  Future<String> createCV(CV cv) async {
    try {
      print('CVService: Creating CV with name: ${cv.name}');
      
      // Create main CV document
      final id = await create(cv);
      print('CVService: Main CV document created with ID: $id');

      // Add subcollections for structured data (use toMap to ensure timestamps)
      try {
        if (cv.experiences != null && cv.experiences!.isNotEmpty) {
          print('CVService: Adding ${cv.experiences!.length} experiences');
          for (var e in cv.experiences!) {
            await collectionRef.doc(id).collection('experiences').add(e.toMap());
          }
        }

        if (cv.educations != null && cv.educations!.isNotEmpty) {
          print('CVService: Adding ${cv.educations!.length} educations');
          for (var ed in cv.educations!) {
            await collectionRef.doc(id).collection('educations').add(ed.toMap());
          }
        }

        if (cv.skills != null && cv.skills!.isNotEmpty) {
          print('CVService: Adding ${cv.skills!.length} skills');
          for (var s in cv.skills!) {
            await collectionRef.doc(id).collection('skills').add(s.toMap());
          }
        }

        if (cv.projects != null && cv.projects!.isNotEmpty) {
          print('CVService: Adding ${cv.projects!.length} projects');
          for (var p in cv.projects!) {
            await collectionRef.doc(id).collection('projects').add(p.toMap());
          }
        }
        
        print('CVService: All subcollections added successfully');
      } catch (e) {
        print('CVService: Error saving subcollections: $e');
        // If subcollection writes fail, delete the created CV to avoid inconsistent state
        await collectionRef.doc(id).delete();
        throw Exception('Error saving subcollections for CV: $e');
      }

      return id;
    } catch (e) {
      print('CVService: Error in createCV: $e');
      rethrow;
    }
  }

  /// Get all CVs as a stream
  @override
  Stream<List<CV>> getAll({
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    return super.getAll(orderBy: orderBy ?? 'createdAt', descending: true, limit: limit);
  }

  /// Get all CVs
  Stream<List<CV>> getAllCVs() => getAll();

  /// Get a single CV and include its subcollections (experiences, educations, skills, projects)
  Future<CV?> getCV(String id) async {
    try {
      final doc = await collectionRef.doc(id).get();
      if (!doc.exists) return null;

      var cv = CV.fromFirestore(doc);

      // Load subcollections
      final expSnap = await collectionRef.doc(id).collection('experiences').get();
      final eduSnap = await collectionRef.doc(id).collection('educations').get();
      final skillSnap = await collectionRef.doc(id).collection('skills').get();
      final projSnap = await collectionRef.doc(id).collection('projects').get();

      final experiences = expSnap.docs.map((d) => Experience.fromJsonFactory(d.data(), docId: d.id)).toList();
      final educations = eduSnap.docs.map((d) => Education.fromJsonFactory(d.data(), docId: d.id)).toList();
      final skills = skillSnap.docs.map((d) => Skill.fromJsonFactory(d.data(), docId: d.id)).toList();
      final projects = projSnap.docs.map((d) => Project.fromJsonFactory(d.data(), docId: d.id)).toList();

      cv = cv.copyWith(experiences: experiences, educations: educations, skills: skills, projects: projects);
      return cv;
    } catch (e) {
      throw Exception('Error fetching CV with subcollections: $e');
    }
  }

  /// Update CV basic info
  Future<void> updateCVInfo(String id, CV cv) async {
    // Update main document
    await update(id, cv);

    // Replace subcollections (simple strategy: delete existing docs then add new ones)
    Future<void> replaceSubcollection(String name, List<Map<String, dynamic>> items) async {
        final coll = collectionRef.doc(id).collection(name);
        final batch = FirebaseFirestore.instance.batch();

        final existing = await coll.get();
        for (var doc in existing.docs) {
          batch.delete(doc.reference);
        }

        for (var item in items) {
          final newDoc = coll.doc();
          batch.set(newDoc, item);
        }

        await batch.commit();
    }

    if (cv.experiences != null) {
      await replaceSubcollection('experiences', cv.experiences!.map((e) => e.toMap()).toList());
    }
    if (cv.educations != null) {
      await replaceSubcollection('educations', cv.educations!.map((e) => e.toMap()).toList());
    }
    if (cv.skills != null) {
      await replaceSubcollection('skills', cv.skills!.map((s) => s.toMap()).toList());
    }
    if (cv.projects != null) {
      await replaceSubcollection('projects', cv.projects!.map((p) => p.toMap()).toList());
    }
  }

  /// Delete a CV
  Future<void> deleteCV(String id) => delete(id);

  /// Duplicate a CV (create a copy)
  Future<String> duplicateCV(String id) async {
    final originalCV = await getCV(id);
    if (originalCV == null) throw Exception('CV not found');

    final duplicated = originalCV.copyWith(
      id: null, // Reset ID so it creates a new document
      name: '${originalCV.name} (Copy)',
    );
    // Use createCV to duplicate including subcollections
    return await createCV(duplicated);
  }

  /// Search CVs by name
  Stream<List<CV>> searchByName(String query) {
    return getAll().map((cvs) {
      return cvs
          .where((cv) => cv.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  /// Get CV count
  Future<int> getCVCount() {
    return super.count();
  }

  /// Get experiences for a CV
  Stream<List<Map<String, dynamic>>> getCVExperiences(String cvId) {
    try {
      return collectionRef
          .doc(cvId)
          .collection('experiences')
          .orderBy('startDate', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      throw Exception('Error fetching CV experiences: $e');
    }
  }

  /// Get educations for a CV
  Stream<List<Map<String, dynamic>>> getCVEducations(String cvId) {
    try {
      return collectionRef
          .doc(cvId)
          .collection('educations')
          .orderBy('startDate', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      throw Exception('Error fetching CV educations: $e');
    }
  }

  /// Get skills for a CV
  Stream<List<Map<String, dynamic>>> getCVSkills(String cvId) {
    try {
      return collectionRef
          .doc(cvId)
          .collection('skills')
          .orderBy('name')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      throw Exception('Error fetching CV skills: $e');
    }
  }

  /// Get projects for a CV
  Stream<List<Map<String, dynamic>>> getCVProjects(String cvId) {
    try {
      return collectionRef
          .doc(cvId)
          .collection('projects')
          .orderBy('createdDate', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      throw Exception('Error fetching CV projects: $e');
    }
  }

  /// Delete experience from CV
  Future<void> deleteExperienceFromCV(String cvId, String experienceId) async {
    try {
      await collectionRef
          .doc(cvId)
          .collection('experiences')
          .doc(experienceId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting experience from CV: $e');
    }
  }

  /// Delete education from CV
  Future<void> deleteEducationFromCV(String cvId, String educationId) async {
    try {
      await collectionRef
          .doc(cvId)
          .collection('educations')
          .doc(educationId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting education from CV: $e');
    }
  }

  /// Delete skill from CV
  Future<void> deleteSkillFromCV(String cvId, String skillId) async {
    try {
      await collectionRef.doc(cvId).collection('skills').doc(skillId).delete();
    } catch (e) {
      throw Exception('Error deleting skill from CV: $e');
    }
  }

  /// Delete project from CV
  Future<void> deleteProjectFromCV(String cvId, String projectId) async {
    try {
      await collectionRef.doc(cvId).collection('projects').doc(projectId).delete();
    } catch (e) {
      throw Exception('Error deleting project from CV: $e');
    }
  }
}
