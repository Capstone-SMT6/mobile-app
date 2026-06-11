import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../auth/auth_service.dart';
import 'package:flutter/foundation.dart';

/// Service for fetching training plans and analytics from the backend.
class PlanService {
  static final _authService = AuthService();

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('User not logged in');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Generate a new training plan based on user's fitness profile.
  /// Returns the full plan data.
  static Future<Map<String, dynamic>> generatePlan({String? fitnessProfileId}) async {
    final headers = await _getAuthHeaders();
    final body = jsonEncode({
      if (fitnessProfileId != null) 'fitness_profile_id': fitnessProfileId,
    });

    final response = await http.post(
      Uri.parse(AppConfig.generatePlanEndpoint),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to generate plan: ${response.statusCode} - ${response.body}');
    }
  }

  /// Fetch the user's currently active plan.
  /// Returns null if no active plan exists.
  static Future<Map<String, dynamic>?> getActivePlan() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse(AppConfig.activePlanEndpoint),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch active plan: ${response.statusCode}');
    }
  }

  /// Fetch analytics summary (total workouts, reps, streaks, etc.)
  static Future<Map<String, dynamic>> getAnalyticsSummary() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse(AppConfig.analyticsSummaryEndpoint),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch analytics: ${response.statusCode}');
    }
  }

  /// Fetch weekly breakdown data.
  static Future<Map<String, dynamic>> getWeeklyAnalytics({int weeks = 4}) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('${AppConfig.analyticsWeeklyEndpoint}?weeks=$weeks'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch weekly analytics: ${response.statusCode}');
    }
  }

  /// Fetch calendar workout days for a given month.
  static Future<List<Map<String, dynamic>>> getCalendarData(int year, int month) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse(AppConfig.analyticsCalendarEndpoint(year, month)),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch calendar data: ${response.statusCode}');
    }
  }
}
