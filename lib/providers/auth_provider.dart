import 'package:cv_project1/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final _auth = AuthService();
  String? get uid => _auth.currentUser?.uid;

  bool _isLoading = false;
  bool _ispasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool get isLoading => _isLoading;
  bool get isPasswordVisible => _ispasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  void setPasswordVisible() {
    _ispasswordVisible = !_ispasswordVisible;
    notifyListeners();
  }

  void setConfirmPasswordVisible() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
        );
        if (_auth.currentUser == null) {
          throw Exception('Login failed: No user found');
        }
    } catch (e) {
      throw Exception('Error signing in: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
        );
        if (_auth.currentUser == null) {
          throw Exception('Registration failed: No user created');
        }
    } catch (e) {
      throw Exception('Error creating user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }


}