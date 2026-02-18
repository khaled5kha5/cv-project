import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService._privateConstructor();
  static final StorageService instance = StorageService._privateConstructor();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadBytes(String path, List<int> bytes) async {
    final ref = _storage.ref().child(path);
    final task = await ref.putData(Uint8List.fromList(bytes));
    return task.ref.getDownloadURL();
  }

  Future<String> uploadProfileImage({
    required String userId,
    required List<int> bytes,
    String fileExtension = 'jpg',
  }) async {
    final safeExtension = fileExtension.toLowerCase().replaceAll('.', '');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'users/$userId/profile_images/profile_$timestamp.$safeExtension';

    final ref = _storage.ref().child(path);
    final task = await ref.putData(
      Uint8List.fromList(bytes),
      SettableMetadata(contentType: 'image/$safeExtension'),
    );
    return task.ref.getDownloadURL();
  }

  Future<List<int>> downloadBytes(String path) async {
    final ref = _storage.ref().child(path);
    final bytes = await ref.getData();
    if (bytes == null) {
      throw Exception('No data found in storage path: $path');
    }
    return bytes;
  }

  Future<void> delete(String path) async {
    await _storage.ref().child(path).delete();
  }
}
