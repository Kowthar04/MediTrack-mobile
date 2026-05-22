import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/auth_storage.dart';

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

      await AuthStorage.saveSession(
        token: token!,
        role: role!,
        fullName: fullName!,
      );

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

  Future<void> logout() async {
    await AuthStorage.clearSession();

    token = null;
    role = null;
    fullName = null;
    errorMessage = null;
    selectedPatientId = null;
    selectedPatientName = null;

    notifyListeners();
  }
}