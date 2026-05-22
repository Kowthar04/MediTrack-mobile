import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _roleKey = 'user_role';
  static const _patientIdKey = 'patient_id';
  static const _fullNameKey = 'full_name';

  static Future<void> saveSession({
    required String token,
    required String role,
    required String fullName,
    int? patientId,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _roleKey, value: role);
    await _storage.write(key: _fullNameKey, value: fullName);

    if (patientId != null) {
      await _storage.write(key: _patientIdKey, value: patientId.toString());
    }
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<String?> getRole() async {
    return await _storage.read(key: _roleKey);
  }

  static Future<String?> getFullName() async {
    return await _storage.read(key: _fullNameKey);
  }

  static Future<int?> getPatientId() async {
    final value = await _storage.read(key: _patientIdKey);
    return value == null ? null : int.tryParse(value);
  }

  static Future<void> clearSession() async {
    await _storage.deleteAll();
  }
}