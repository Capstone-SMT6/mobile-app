import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../auth/auth_service.dart';
import '../models/user_model.dart';

class UserService {
  static final _authService = AuthService();

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('User not logged in');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<User> getCurrentUser() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse(AppConfig.meEndpoint),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch user: ${response.statusCode}');
    }
  }

  static Future<UserStats> getUserStats() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse(AppConfig.meStatsEndpoint),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return UserStats.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch user stats: ${response.statusCode}');
    }
  }

  static Future<UserFitnessProfile> getFitnessProfile() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse(AppConfig.meFitnessProfileEndpoint),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return UserFitnessProfile.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      // Handle case where profile doesn't exist yet
      throw Exception('Fitness profile not found. Please complete onboarding.');
    } else {
      throw Exception('Failed to fetch fitness profile: ${response.statusCode}');
    }
  }

  static Future<User> uploadAvatar(String userId, String filePath) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('User not logged in');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.usersEndpoint}/$userId/avatar'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to upload avatar: ${response.statusCode}');
    }
  }
}
