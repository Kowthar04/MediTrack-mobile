import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String? token;
  String? role;
  String? fullName;
  String? errorMessage;
  int? selectedPatientId;
  String? selectedPatientName;

  bool isLoading = false;

  bool get isLoggedIn => token != null;

  Future<bool> login({
    required String email,
    required String password,
    required String selectedRole,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(
        email: email,
        password: password,
        role: selectedRole,
      );

      token = result['token'];
      role = result['role'];
      fullName = result['full_name'];

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    token = null;
    role = null;
    fullName = null;
    errorMessage = null;
    notifyListeners();
  }
}