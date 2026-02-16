import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  
  final _auth = FirebaseAuth.instance;

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email, 
      password: password,
      );
  }

  Future<UserCredential> register(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email, 
      password: password,
      );
  }

  

  Future<void> signOut() async {
    return await _auth.signOut();
  }
}
