import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';


class StorageService {
  final _storage = FirebaseStorage.instance;
  
  
  Future<String> uploadphoto({
    required String userId,
    required List<int> fileBytes,
    required String fileExtension,
  }) async {
    final safeExtension = fileExtension.toLowerCase().replaceAll('.', '');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = "users/$userId/profile_images/profile_$timestamp.$safeExtension";

    final ref = _storage.ref().child(path);
    final task = await ref.putData(
      Uint8List.fromList(fileBytes), 
      SettableMetadata(contentType: 'image/$safeExtension'));

    return task.ref.getDownloadURL();

  }

}