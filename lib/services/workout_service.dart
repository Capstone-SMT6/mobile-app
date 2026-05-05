import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../auth/auth_service.dart';

class WorkoutService {
  static final _authService = AuthService();

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('User not logged in');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Simpan sesi latihan ke backend, return streak terbaru
  static Future<Map<String, dynamic>> saveSession({
    int durationSeconds = 0,
    List<Map<String, dynamic>> logs = const [],
  }) async {
    final headers = await _getAuthHeaders();
    final body = jsonEncode({
      'duration_seconds': durationSeconds,
      'logs': logs,
    });

    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/api/workouts/sessions'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to save workout session: ${response.statusCode}');
    }
  }

  /// Ambil semua sesi latihan (untuk kalender)
  static Future<List<DateTime>> getSessionDates() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/api/workouts/sessions'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((s) => DateTime.parse(s['date'] as String)).toList();
    } else {
      throw Exception('Failed to fetch sessions: ${response.statusCode}');
    }
  }
}
