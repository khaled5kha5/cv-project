import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/base_model.dart';

/// Generic Firestore CRUD service for any BaseModel
abstract class FirestoreService<T extends BaseModel> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  /// Get current user ID - throws if not authenticated
  String get uid {
    final user = auth.currentUser;
    print('FirestoreService: Checking authentication...');
    print('FirestoreService: currentUser = $user');
    if (user == null) {
      throw Exception('Not authenticated. Please sign in to perform this action.');
    }
    print('FirestoreService: User authenticated with UID = ${user.uid}');
    print('FirestoreService: User email = ${user.email}');
    return user.uid;
  }

  /// Get the Firestore collection reference for this model
  /// Override this in subclasses to specify the collection path
  CollectionReference<Map<String, dynamic>> get collectionRef;

  /// Create model from JSON data
  T fromJson(Map<String, dynamic> json, {String? docId});

  /// Convert model to JSON
  Map<String, dynamic> toJson(T model);

  /// Create/Add a new document
  Future<String> create(T model) async {
    try {
      print('FirestoreService: Getting UID...');
      final userId = uid; // This will throw if not authenticated
      print('FirestoreService: UID = $userId');
      
      print('FirestoreService: Converting model to JSON...');
      final data = toJson(model);
      print('FirestoreService: Data = $data');
      
      // ensure timestamps exist
      data['createdAt'] ??= FieldValue.serverTimestamp();
      data['updatedAt'] ??= FieldValue.serverTimestamp();

      print('FirestoreService: Adding document to Firestore...');
      final docRef = await collectionRef.add(data);
      print('FirestoreService: Document created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e, stackTrace) {
      print('FirestoreService: Error creating document: $e');
      print('FirestoreService: Stack trace: $stackTrace');
      throw Exception('Error creating document: $e');
    }
  }

  /// Read a single document by ID
  Future<T?> read(String id) async {
    try {
      final doc = await collectionRef.doc(id).get();
      if (!doc.exists) return null;
      return fromFirestore(doc);
    } catch (e) {
      throw Exception('Error reading document: $e');
    }
  }

  /// Update a document
  Future<void> update(String id, T model) async {
    try {
      // Only send changed fields; ensure updatedAt is set server-side
      final data = model.toUpdateMap();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await collectionRef.doc(id).update(data);
    } catch (e) {
      throw Exception('Error updating document: $e');
    }
  }

  /// Delete a document
  Future<void> delete(String id) async {
    try {
      await collectionRef.doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting document: $e');
    }
  }

  /// Get all documents as a stream
  Stream<List<T>> getAll({
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    try {
      Query<Map<String, dynamic>> query = collectionRef;

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => fromJson(doc.data(), docId: doc.id)).toList();
      }).handleError((e) {
        debugPrint('Firestore stream error: $e');
      });
    } catch (e) {
      throw Exception('Error in getAll query: $e');
    }
  }

  /// Helper to create model from a DocumentSnapshot. Subclasses may override
  /// `fromJson` but this provides a default that preserves doc id.
  T fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return fromJson(data, docId: doc.id);
  }

  DocumentSnapshot? _lastDoc;

  /// Simple pagination helper that fetches the next page of documents.
  Future<List<T>> fetchNextPage(int pageSize, {String? orderBy, bool descending = false}) async {
    try {
      Query<Map<String, dynamic>> query = collectionRef;
      if (orderBy != null) query = query.orderBy(orderBy, descending: descending);
      query = query.limit(pageSize);
      if (_lastDoc != null) query = query.startAfterDocument(_lastDoc!);
      final snap = await query.get();
      if (snap.docs.isNotEmpty) _lastDoc = snap.docs.last;
      return snap.docs.map((doc) => fromJson(doc.data(), docId: doc.id)).toList();
    } catch (e) {
      throw Exception('Error fetching next page: $e');
    }
  }

  /// Get paginated documents
  Stream<List<T>> getPaginated({
    required int pageSize,
    String? orderBy,
    bool descending = false,
  }) {
    try {
      Query<Map<String, dynamic>> query = collectionRef;

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      return query.limit(pageSize).snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => fromJson(doc.data(), docId: doc.id))
            .toList();
      });
    } catch (e) {
      throw Exception('Error fetching paginated documents: $e');
    }
  }

  /// Query documents with a where clause
  Stream<List<T>> query({
    required String field,
    required dynamic value,
    String? orderBy,
    bool descending = false,
  }) {
    try {
      Query<Map<String, dynamic>> q = collectionRef.where(field, isEqualTo: value);

      if (orderBy != null) {
        q = q.orderBy(orderBy, descending: descending);
      }

      return q.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => fromJson(doc.data(), docId: doc.id))
            .toList();
      });
    } catch (e) {
      throw Exception('Error querying documents: $e');
    }
  }

  /// Batch write multiple documents
  Future<void> batchWrite(List<T> models) async {
    try {
      final batch = db.batch();
      for (var model in models) {
        batch.set(collectionRef.doc(), toJson(model));
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Error in batch write: $e');
    }
  }

  /// Batch update multiple documents
  Future<void> batchUpdate(Map<String, T> updates) async {
    try {
      final batch = db.batch();
      updates.forEach((id, model) {
        batch.update(collectionRef.doc(id), toJson(model));
      });
      await batch.commit();
    } catch (e) {
      throw Exception('Error in batch update: $e');
    }
  }

  /// Batch delete multiple documents
  Future<void> batchDelete(List<String> ids) async {
    try {
      final batch = db.batch();
      for (var id in ids) {
        batch.delete(collectionRef.doc(id));
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Error in batch delete: $e');
    }
  }

  /// Count documents
  Future<int> count({String? field, dynamic value}) async {
    try {
      Query<Map<String, dynamic>> query = collectionRef;
      if (field != null && value != null) {
        query = query.where(field, isEqualTo: value);
      }
      final snapshot = await query.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Error counting documents: $e');
    }
  }

  /// Check if a document exists
  Future<bool> exists(String id) async {
    try {
      final doc = await collectionRef.doc(id).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Error checking document existence: $e');
    }
  }
}
