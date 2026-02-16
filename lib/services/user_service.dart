import 'base_service.dart';

class UserService extends BaseService {
  
  Stream<Map<String, dynamic>> getUserInfo() {
    return db
    .collection('users')
    .doc('uid')
    .snapshots()
    .map((doc) => doc.data() ?? {});
  }

  Future<void> saveUserInfo(Map<String, dynamic> data) async {
    await db
    .collection('users')
    .doc('uid')
    .set(data);
  }
}
