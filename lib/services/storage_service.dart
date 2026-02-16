/// Storage service stub. To enable real uploads/downloads, add `firebase_storage`
/// to `pubspec.yaml` and implement the methods below.

class StorageService {
  Future<String> uploadBytes(String path, List<int> bytes) async {
    throw UnimplementedError('Add firebase_storage and implement uploadBytes');
  }

  Future<List<int>> downloadBytes(String path) async {
    throw UnimplementedError('Add firebase_storage and implement downloadBytes');
  }

  Future<void> delete(String path) async {
    throw UnimplementedError('Add firebase_storage and implement delete');
  }
}
