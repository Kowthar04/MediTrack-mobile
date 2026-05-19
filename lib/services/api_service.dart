import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = AuthService.baseUrl;

  Future<Map<String, dynamic>> getPatientHome(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/mobile/patient/home'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> getPatientSchedule(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/mobile/patient/schedule'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handle(res);
  }

  Future<void> logDose(String token, String time, {int? patientId}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/mobile/log-dose'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'time': time,
        if (patientId != null) 'patient_id': patientId,
      }),
    );
    _handle(res);
  }

  Future<Map<String, dynamic>> getCaregiverPatients(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/mobile/caregiver/patients'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> getCaregiverPatientHome(
      String token,
      int patientId,
      ) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/mobile/caregiver/patient/$patientId/home'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> addCaregiverNote(
      String token,
      int patientId,
      String noteText,
      String? tag,
      ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/mobile/caregiver/patient/$patientId/notes'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'note_text': noteText,
        'tag': tag,
      }),
    );
    return _handle(res);
  }

  Map<String, dynamic> _handle(http.Response res) {
    final data = jsonDecode(res.body);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(data['error'] ?? 'Request failed');
    }
    return data;
  }

  Future<void> saveWellbeing({
    required String token,
    required String mood,
    required String energy,
    required String sideEffects,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/mobile/wellbeing'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'mood': mood,
        'energy': energy,
        'side_effects': sideEffects,
      }),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to save wellbeing check-in');
    }
  }
}